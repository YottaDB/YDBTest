;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Portions Copyright (c) Fidelity National			;
; Information Services, Inc. and/or its subsidiaries.		;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Helper routine for ydb531_v6tov7.csh test to initialize the upgrade engine for both methods. Certain common
; elements need to be dealt with before getting to the particulars of each type of upgrade. In this routine we:
;   1. Dump the triggers for the V6 databases.
;   2. Create new subdirs for the two upgrade methods (V7XtrLoadDBs and V7MergedDBs).
;   3. Copy the original V6 global directory to each subdir.
;   4. Run MakeGLDFullPath^DBUpgradeMethods() on the main directory and the two subdirs so all global directories
;      have had the database references in them converted to use full paths. This is the only way we can use
;      extended references in this environment and refer to the correct databases.
;   5. Create the databases in the subdirs.
;   6. After both V7 subdirs have had the global directory copied to them and made full-path, do the same for
;      the V6 DB global directory. This will be needed later when we extract and load triggers and when we do
;      the upgrade by MERGE.
UpgradeInit
	set dotriggers=$ztrnlnm("gtm_test_trigger")
	set $etrap="use $p zwrite $zstatus zshow ""*"" break  zhalt 1"
	write !!,"**********************************************************************************************",!
	write !,"# Start upgrade initialization (UpgradeInit^DBUpgradeMethods)",!
	write "# Note - we may bypass some steps (like step #1) that are trigger specific if this run does not have triggers",!
	set gbldir=$ztrnlnm("gtmgbldir")
	set curV6dir=$zdirectory		; Grab current working directory (V6 aka main subdir)
	set curV6dir=curV6dir_$select($zextract(curV6dir,$zlength(curV6dir))="/":"",1:"/")
	set curV6gbldir=curV6dir_gbldir
	do:dotriggers
	. set V6TrigDefs="V6TriggerDefs.txt"
	. write !,"# Step 1: Dump V6 triggers to file ",V6TrigDefs,!
	. do DumpTriggers(curV6dir,V6TrigDefs)
	write !,"# Run steps 2 through 5 on each of our V7 subdirectories (V7XtrLoadDBs and V7MergedDBs):",!
	for subdir="V7XtrLoadDBs","V7MergedDBs" do
	. write !!,"***********************************************************************",!
	. write:"V7XtrLoadDBs"=subdir !,"# Upgrade databases in the main directory from V6 to V7 DBs by the MUPIP EXTRACT/LOAD method:",!
	. write:"V7MergedDBs"=subdir !,"# Upgrade databases in the main directory from V6 to V7 DBs by the MERGE method:",!
	. write !,"# Step 2: Create subdir for DBs (",subdir,"):",!
	. do CommandToPipe("mkdir "_subdir,.results)
	. if (0'=results(0)) do fatalerr("Unable to create "_subdir_" subdir",.results)
	. write !,"# Step 3: Copy global directory to subdirectory "_subdir,!
	. do CommandToPipe("cp "_curV6gbldir_" "_curV6dir_"/"_subdir_"/"_gbldir,.results)
	. if (0'=results(0)) do fatalerr("Unable to copy global directory",.results)
	. write !,"# Step 4: Force database references in the V7 GLD to be full path",!
	. set $zdirectory=curV6dir_"/"_subdir
	. ;
	. ; For the duration of this DO, we have $zgbldir reset to our inner V7 DB - otherwise trigger loads don't
	. ; work correctly as a 'mumps.gld' is already loaded from the V6 directory so it won't load another one.
	. ;
	. do
	. . new $zgbldir
	. . set $zgbldir=$zdirectory_gbldir
	. . do MakeGLDFullPath
	. . write !,"# Step 5: Create the V7 DBs",!
	. . zsystem "$gtm_dist/mupip create"
	. set $zdirectory=curV6dir
	;
	; One last task is to convert the original V6 global directory to also have full paths.
	;
	write !,"***********************************************************************",!
	write !,"# Step 6: Convert (main dir) V6 DB global directory to have full paths",!
	do MakeGLDFullPath
	write !!,"**********************************************************************************************",!
	quit

;
; Helper routine for ydb531_v6tov7.csh test script to upgrade the DB by MUPIP EXTRACT/LOAD
;
; This routine:
;   1. Load binary V6 dump to databases.
;   2. Create extracts from the V7 database of both triggers and data used for later verification.
;
UpgradeByXtrLoad
	set dotriggers=$ztrnlnm("gtm_test_trigger")
	set $etrap="use $p zwrite $zstatus zshow ""*"" break  zhalt 1"
	set curdir=$zdirectory
	write !,"# Upgrade databases in the main directory from V6 to V7 DBs by the MUPIP EXTRACT/LOAD method:",!
	;
	; Step 1: Load binary V6 dump to V7 databases. Needs to run in a separate process from us so
	;         the DBs we've already opened don't interfere.
	;
	set $zdirectory=curdir_"V7XtrLoadDBs"		; Make subdir for extract/load the current directory
	write !,"# Load the V6 extract created during initialization",!
	zsystem "$gtm_dist/mupip load ../V6OrigDBs.bin |& tee ../loadV6DBbin.out"
	set $zdirectory=curdir				; Restore current directory
	do UpgradeEpilogue($zdirectory,"V7XtrLoadDBs")
	zhalt 0

;
; Helper routine for ydb531_v6tov7.csh test script to upgrade the DB  by using the MERGE command. Note, requires
; $gtmgbldir to be 'mumps.gld' or similar filename with no path.
;
; This routine:
;   1. $ORDER() through list of globals starting with ^%.
;   2. For each global, use the MERGE command to migrate the global from the V6 DBs to the V7 DBs using extended references.
;
; Note that this routine outputs the list of globals merged and their counts but since imptp is a random data
; generator, these values are not predictable from run to run so these variable outputs are output to a file but
; the rest of IO is written to $PRINCIPAL.
;
UpgradeByMerge
	set dotriggers=$ztrnlnm("gtm_test_trigger")
	set $etrap="use $p zwrite $zstatus zshow ""*"" break  zhalt 1"
	set outfn="UpgradeByMerge_output.txt"
	open outfn:new
	set nopathgld=$ztrnlnm("gtmgbldir")
	set curgbldir=$zdirectory_nopathgld
	set v7gbldir=$zdirectory_"V7MergedDBs/"_nopathgld
	write !,"# Upgrade databases in the main directory from V6 to V7 DBs by the MERGE method:",!
	use outfn  ; Repeat output header for file
	write "# Upgrade databases in the main directory from V6 to V7 DBs by the MERGE method:",!!
	set nextGblRef="^%"
	set gblcnt=0
	for  set nextGblRef=$order(@nextGblRef) quit:""=nextGblRef  do		; $ORDER through the globals
	. set gblcnt=gblcnt+1
	. set nextGblName=$zextract(nextGblRef,2,99)				; Strip the '^' prefix off the front (not needed)
	. write "Merging global: ",nextGblRef,!
	. xecute "merge ^|v7gbldir|"_nextGblName_"=^|curgbldir|"_nextGblName	; Merge the global to the V7 DB
	write !,"Total of ",gblcnt," globals merged from V6 to V7 DBs",!
	use $p
	close outfn	; Subsequent output goes to the reference file
	do UpgradeEpilogue($zdirectory,"V7MergedDBs")
	quit

;
; Routine called by UpgradeByXtrLoad and UpgradeByMerge to load the triggers in the database after the upgrade of
; the data has been completed. We do this because MERGE would drive the triggers were they in the DB while the
; MUPIP LOAD would not. Note that this routine creates the TrigDefsInV7XtrLoadExtract.txt and TrigDefsInV7MergedDBsExtract.txt
; trigger extract files that are used in extract comparisons in the main test script. Steps in this routine:
;   1. Load the triggers into the new database.
;   2. Create a trigger extract to compare later
;
UpgradeEpilogue(curdir,subdir)
	do:dotriggers
	. set V6TrigDefs="V6TriggerDefs.txt"
	. write !,"# Load triggers into database now that all data is loaded",!
	. do LoadTriggers(curdir_subdir,curdir_V6TrigDefs,"TrigDefsIn"_subdir_".txt")
	. write !,"# Create trigger extract from the V7 DB for comparison cases later",!
	. do DumpTriggers(curdir_subdir,"TrigDefsIn"_subdir_"Extract.txt")
	quit

;
; Routine to dump triggers from one or more databases in a given directory to a given output file
;
DumpTriggers(dir,outfile)
	new savedir,xstr
	set savedir=$zdirectory
	set $zdirectory=dir
	set xstr="set $zgbldir="""_$zdirectory_$ztrnlnm("gtmgbldir")_""" if $ztrigger(""select"")"
	zsystem "$gtm_dist/mumps -run ^%XCMD '"_xstr_"' >& "_outfile
	set $zdirectory=savedir
	quit

;
; Routine to load dumpped triggers to one or more databases in a given directory from a given file with any
; output going to a given file.
;
LoadTriggers(dir,trigdefs,outfile)
	new savedir,xstr
	set savedir=$zdirectory
	set $zdirectory=dir
	set xstr="set $zgbldir="""_$zdirectory_$ztrnlnm("gtmgbldir")_""" if $ztrigger(""file"","""_trigdefs_""")"
	zsystem "$gtm_dist/mumps -run ^%XCMD '"_xstr_"' >& "_outfile
	set $zdirectory=savedir
	quit

;
; Turn the database references in the global directory to use full-path database names.
;
MakeGLDFullPath
	new i,results,line,segcnt,segment,dbname
	new $etrap
	set $etrap="use $p zwrite $zstatus zshow ""*"" break  zhalt 1"
	;
	; Get list of segments (DBs) and their filenames - Run this as a separate process so this process does not open
	; the global directory before it is modified.
	;
	do CommandToPipe("$gtm_dist/mumps -run GDE show -segment",.results)
	;
	; Ignore all results until see '--------' line that signals start of segments
	;
	for i=1:1:results(0) quit:(" ----------"=$zextract(results(i),1,11))
	;
	; From here on out, each line that starts with a character should be a segment start line where the next
	; token contains the database name. Record both of these ignoring all other lines.
	;
	set segcnt=0
	for i=i+1:1:results(0) do
	. quit:("  "=$zextract(results(i),1,2))
	. quit:("%GDE-I-NOACTION"=$zextract(results(i),1,15))
	. write:("%"=$zextract(results(i),1)) line
	. set line=$$EliminateExtraWhiteSpace(results(i))
	. set segment($incr(segcnt))=$zpiece(line," ",2)
	. set dbname(segcnt)=$zpiece(line," ",3)
	;
	; For each database, execute a command to change the file name in the global directory to a fully qualified
	; name, else the merge won't work because we have the same globals in both the original DB and the new V7
	; copy of the DB. So we will use extended references but then the DBs need to be fully qualified.
	;
	for i=1:1:segcnt do
	. do CommandToPipe("$gtm_dist/mumps -run GDE change -seg "_segment(i)_" -file="_$zdirectory_dbname(i),.results)
	quit

;
; Routine to raise a fatal error and stop
;
fatalerr(msg,results)
	use $p
	write !!,message," (results dump follows):",!
	zwrite results
	zhalt 1

;
; Routine to execute a command in a pipe and return the executed lines in an array (taken from secshr/inref/checkftok.m)
;
CommandToPipe(cmd,results)
	new pipecnt,pipe,saveIO
	kill results
	set pipe="CmdPipe"
	set saveIO=$io
	open pipe:(shell="/bin/sh":command=cmd)::"PIPE"
	use pipe
	set pipecnt=1
	for  read results(pipecnt) quit:$zeof  set pipecnt=pipecnt+1
	close pipe
	set results(0)=pipecnt-1
	kill results(pipecnt)
	use saveIO
	quit

;
; Eliminate multiple sequential white space chars to promote parsing with $[z]piece (taken from secshr/inref/checkftok.m)
;
EliminateExtraWhiteSpace(str)
	new lastch,sp,len,newstr
 	set str=$translate(str,$char(9)," ")	; Convert tabs to spaces first
	set len=$zlength(str)
	set lastch=1,newstr=""
	for  quit:lastch>len  do
	. set sp=$zfind(str," ",lastch)
	. if (0<sp) do
	. . set newstr=newstr_$zextract(str,lastch,sp-1)
	. . for lastch=sp:1:len+1 quit:(" "'=$zextract(str,lastch))	; Going to plus 1 terminates the loop
	. else  set newstr=newstr_$zextract(str,lastch,len),lastch=len+1
	set str=newstr
	quit:$quit str quit
