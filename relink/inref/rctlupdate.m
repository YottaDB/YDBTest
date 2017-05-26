;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize and drive the test by first defining/obtaining key configuration settings, populating necessary file   ;
; argument arrays for further file system and ZRUPDATE operations, and cycling repeatedly through all the arguments ;
; in a random order.                                                                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rctlupdate
	new i,j,pwd,dir,files,dirs,args,matches,file,extension,name,directory,expectError,count,objects,error,found,setup,zdirectory,cycles,results
	new FMODE,TRUE,FALSE,LOG,NUMOFLOOPS

	set NUMOFLOOPS=50

	set TRUE=1
	set FALSE=0
	if $&gtmposix.filemodeconst("S_IRWXU",.FMODE)
	set LOG="log.txt"
	open LOG:newversion

	set pwd=$ztrnlnm("PWD")
	set dir="testing"

	set files="a.m b.m a.o b.o abc abc.o cba _def _ghi.o _jk_lm.o n-o-p.o bbb.o c.m .o d.m.o d.abc a_b.o %ccc.o l2cba.o l2cba l2adoto.m l2adoto.o l2adoto l2dir1adoto.o"
	set dirs="dir1 dir2 l2dir1 . "
	set args="* */* dir* dir*/* dir1 dir2/ dir1/* dir1/*.* dir2/*.m dir2/* dir1/a* dir2/b* dir1/*.m dir2/*.o dir3* dir3/* dir3/a.o "
	set args=args_"? */? dir? dir?/* dir1/? dir2/?.? dir?/?.? dir1/?.* dir2/*.? dir?/???* dir1/?* dir2/b* dir1/?.m dir2/?.o dir3? dir3/?.* dir?/a.o"
	for i=1:1:$length(files," ") set args=args_" "_$piece(dirs," ",i#5+1)_$select((i+1)#5<2:"",1:"/")_$piece(files," ",i)
	for i=1:1:$length(args," ") set args=args_" "_pwd_"/"_dir_"/"_$piece(args," ",i)
	set args=args_" "_pwd_"/"_dir_"/../"_dir_"/dir1/*.o "_pwd_"/"_dir_"/dir2/.././/dir2/*.o dir1/../dir2/*.o dir2///./../dir1/./*.o"
	set args=args_" "_pwd_"/"_dir_"/l2dir1/*.o l2dir1/..//..//"_dir_"/./dir2/*.o "_pwd_"/"_dir_"/.///./dir1/.././/dir1/dir0///./../*.o"
	set args=args_" dir$one/*.o dir$two/*.o dir$one//./../dir$two/*.o $PWD/* dir[123]/* dir?/[]*.o"

	do populate(.files)
	do populate(.dirs)
	do populate(.args)

	set zdirectory=$zdirectory

	for n=1:1:NUMOFLOOPS do
	.	do log("======= ITERATION "_n_" =======")
	.
	.	; Randomize the order of arguments.
	.	do randomize(.args)
	.
	.	; Make sure the directory for testing does not exist (mainly for manual runs).
	.	do &relink.removeDirectory(zdirectory_dir)
	.
	.	; Create and (make it our current) working directory for this iteration.
	.	if $&gtmposix.mkdir(zdirectory_dir,FMODE,.errno)
	.	set $zdirectory=zdirectory_dir
	.
	.	; Create random files in the current working directory.
	.	do createRandomFiles(.dirs,.files,.setup)
	.
	.	; Go through all possible ZRUPDATE arguments.
	.	for i=1:1:args(0) do
	.	.	do log("------- Arg #"_i_": "_args(i)_" --------")
	.	.
	.	.	; Based on the created files, determine the expected outcome of the subsequent ZRUPDATE.
	.	.	do setExpectations(args(i),.setup,.cycles,.expect)
	.	.
	.	.	; Do a ZRUPDATE. Capture any errors.
	.	.	do
	.	.	.	new $etrap
	.	.	.	set $etrap="set error=$zstatus,$ecode="""""
	.	.	.	set error=""
	.	.	.	zrupdate args(i)
	.	.
	.	.	; Extract information from the current relinkctl files.
	.	.	do getResults(.results)
	.	.
	.	.	; Validate our expectations.
	.	.	do validate(.results,.expect,.cycles,error)
	.
	.	; Back things up.
	.	do &relink.removeDirectory(zdirectory_"test"_n)
	.	if $&relink.renameFile(zdirectory_dir,zdirectory_"test"_n)

	; If we got to the very end, clean everything up.
	for n=1:1:NUMOFLOOPS do &relink.removeDirectory(zdirectory_"test"_n)

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set our expectation of which directories should get their relinkctl files initialized and which routines should   ;
; get their cycles bumped, based on the current state of these directories and routines, ZRUPDATE argument, and the ;
; randomly chosen file system configuration.                                                                        ;
;                                                                                                                   ;
; Arguments: arg    - ZRUPDATE argument.                                                                            ;
;            setup  - Container with information about current file system configuration.                           ;
;            cycles - Container with information about routine cycles.                                              ;
;            expect - Container to populate with information about routine cycle updates.                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setExpectations(arg,setup,cycles,expect)
	new i,matchString,index,noresult,count,wildcarded,extension,seenExt,stop,parse,directory,realDir,objDir,name,searchArg,processedArg,errno

	; 	IF type is clearly bad (that is, it may not possibly be valid regardless of the wildcards, if any), expect "FILEPARSE ...; TEXT, Unsupported filetype specified" error.
	; 	IF name is clearly bad (that is, it may not possibly be valid regardless of the wildcards, if any), expect "FILEPARSE ...; TEXT, Filename is not a valid routine name" error.
	;	IF no results AND non-wildcarded, expect "FILEPARSE ...; TEXT, No object files found" soft error.
	;	IF non-wildcarded AND file induces access errors (such as symbolic link loops), expect "FILEPARSE ...; SYSTEM-E-ENOXX, ..." error.
	;	IF non-wildcarded AND object directory does not exist and never existed, expect "FILEPARSE ...; SYSTEM-E-ENOXX, ..." error.
	;	IF non-wildcarded AND file does not exist and never existed, expect "FILEPARSE ...; SYSTEM-E-ENOXX, ..." error.
	;	Otherwise, expect cycle update.

	kill expect
	set stop=FALSE

	; Expand all environment variables.
	set processedArg=$$expandEnvvars(arg)

	; Find out whether the pattern contains wildcards.
	set wildcarded=(processedArg["*")!(processedArg["?")

	; Extract directory, name, and extension from the pattern.
	do parsePattern(processedArg,.parse)

	do log(" - @ point 1")

	; Validate whether the extension may possibly be valid considering the use of wildcards.
	set name=parse("name")
	if (""'=name) do
	.	for i=1:1 set char=$extract(name,i) quit:(stop)!(""=char)  do
	.	.	set:(("*"'=char)&("?"'=char))&(((1=i)&("_"'=char)&(char'?1A))!((1'=i)&(char'?1(1A,1N)))) stop=TRUE
	else  if ('wildcarded) do
	.	set stop=TRUE
	if (stop) do  quit
	.	set expect("error",1)="GTM-E-FILEPARSE, Error parsing file specification: "_arg
	.	set expect("error",2)="GTM-I-TEXT, Filename is not a valid routine name"

	; Validate whether the name may possibly be valid considering the use of wildcards.
	set extension=parse("ext")
	set seenExt=FALSE
	if (""'=extension) do
	.	for i=2:1 set char=$extract(extension,i) quit:(stop)!(""=char)  do:("*"'=char)
	.	.	set:((seenExt!(("o"'=char)&("?"'=char)))) stop=TRUE
	.	.	set seenExt=TRUE
	else  if ('wildcarded) do
	.	set stop=TRUE
	if (stop) do  quit
	.	set expect("error",1)="GTM-E-FILEPARSE, Error parsing file specification: "_arg
	.	set expect("error",2)="GTM-I-TEXT, Unsupported filetype specified"
	do log(" - @ point 2")

	; Prepare the argument for searching with relink.matchFiles().
	set searchArg=$select(("/"'=$extract(processedArg,1)):$zdirectory_processedArg,1:processedArg)
	set searchArg=$$canonicalizePath(searchArg)
	set searchArg=$$escapeBrackets(searchArg)
	set matchString=$&relink.matchFiles(searchArg)
	do log(" - matchString is "_matchString)

	set count=0
	set index=0
	for  do  quit:stop
	.	set file=$piece(matchString,$char(1),$increment(index))
	.	set noresult=(""=file)
	.
	.	if (noresult) do  quit:stop
	.	.	if (wildcarded) do
	.	.	.	set stop=TRUE
	.	.	else  do
	.	.	.	set file=processedArg
	.
	.	do log(" - file is "_file)
	.	do parsePattern(file,.parse)
	.	do log(" - parse.dir = "_parse("dir")_"; parse.name = "_parse("name")_"; parse.ext = "_parse("ext"))
	.
	.	set directory=parse("dir")
	.	set name=parse("name")
	.	set extension=parse("ext")
	.
	.	quit:(wildcarded&((".o"'=extension)!(name'?1(1"_",1A).(1A,1N))))
	.	do log(" - @ point 3")
	.
	.	do &gtmposix.realpath($select(""=directory:".",1:directory),.realDir,.errno)
	.	set:(""'=realDir) realDir=realDir_"/",expect(realDir)=1
	.	do log(" - realDir is "_realDir)
	.
	.	; Consideration for future improvement: It would be nice to also induce "Permission denied" error due to ownership
	.	; by a different user, but currently it is impractical because of associated overheads in the test system.
	.	if ((directory["dir4")!(directory["dir3")) do:('wildcarded)  quit		; Note the quit.
	.	.	set expect("error",1)="GTM-E-FILEPARSE, Error parsing file specification: "_arg
	.	.	set:("/"'=$extract(directory)) directory=$zdirectory_directory
	.	.	do &gtmposix.realpath($$canonicalizePath(directory_"/.."),.realDir,.errno)
	.	.	set:(""'=realDir) realDir=realDir_"/"
	.	.	if ('$data(setup(realDir,"dir3"))) set expect("error",2)="SYSTEM-E-ENO2, No such file or directory"
	.	.	else  do
	.	.	.	if ($zversion["Solaris") set expect("error",2)="SYSTEM-E-ENO90, Number of symbolic links encountered during path name traversal exceeds MAXSYMLINKS"
	.	.	.	else  if ($zversion["AIX") set expect("error",2)="SYSTEM-E-ENO85, Too many levels of symbolic links"
	.	.	.	else  set expect("error",2)="SYSTEM-E-ENO40, Too many levels of symbolic links"
	.	.	set stop=TRUE
	.	do log(" - @ point 4")
	.
	.	if ($data(setup(realDir,"unreadable"))) do:('wildcarded)  quit			; Note the quit.
	.	.	set expect("error",1)="GTM-E-FILEPARSE, Error parsing file specification: "_arg
	.	.	set expect("error",2)="SYSTEM-E-ENO13, Permission denied"
	.	.	set stop=TRUE
	.	do log(" - @ point 5")
	.
	.	quit:(wildcarded&(name["l2"))
	.	do log(" - @ point 6")
	.
	.	set objDir=$select(""=realDir:$select("/"=$extract(directory,1):directory,1:$zdirectory_directory),1:realDir)
	.	do log(" - objDir is "_objDir)
	.
	.	; If the directory does not exist and never existed, expect an error.
	.	if (noresult&(""=realDir)&('$data(cycles(objDir)))) do:('wildcarded)  quit 	; Note the quit.
	.	.	set expect("error",1)="GTM-E-FILEPARSE, Error parsing file specification: "_arg
	.	.	set expect("error",2)="SYSTEM-E-ENO2, No such file or directory"
	.	.	set stop=TRUE
	.	do log(" - @ point 7")
	.
	.	; If the file does not exist and never existed, continue to the next iteration.
	.	if (('wildcarded)&noresult&('$data(cycles(objDir,name_extension)))) set stop=TRUE quit
	.	do log(" - @ point 8")
	.
	.	if $increment(expect(objDir,name_extension)) set count=count+1
	.	set:('wildcarded) stop=TRUE

	if (wildcarded&(0=count)&("+1^GTM$DMOD"=$stack(0,"PLACE"))) do
	.	set expect("error",1)="GTM-I-FILEPARSE, Error parsing file specification: "_arg
	.	set expect("error",2)="GTM-I-TEXT, No object files found"

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extract information about object directories, their respective routines, and the routines' cycles from the output ;
; of ZSHOW "A" command.                                                                                             ;
;                                                                                                                   ;
; Arguments: results - Container to populate with the information extracted from the ZSHOW "A" output.              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getResults(results)
	new i,rctldump,line,dir,name,cycle

	zshow "A":rctldump
	for i=1:1 set line=$get(rctldump("A",i)) quit:(""=line)  do
	.	if (line["Object Directory") do
	.	.	set dir=$piece(line,": ",2)_"/"
	.	.	set results(dir)=1
	.	else  if (line["rec#") do
	.	.	set name=$piece(line," ",7)_".o"
	.	.	set:("%"=$extract(name,1)) name="_"_$extract(name,2,$length(name))
	.	.	set cycle=$piece(line," ",10)
	.	.	set results(dir,name)=1
	.	.	set results(dir,name,"cycle")=cycle
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Validate the expectations we had set earlier against the actual outcome of a ZRUPDATE on the specified argument.  ;
;                                                                                                                   ;
; Arguments: results - Container with the results of the ZRUPDATE command, such as cycles of all routines involved. ;
;            expect  - Container with the expectations we had previously set.                                       ;
;            cycles  - Container with the cycle information about every routine involved.                           ;
;            error   - String container the error message if an error occurred.                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validate(results,expect,cycles,error)
	new dir,name,cycle,stop,fullText

	set stop=FALSE,dir=""
	for  set dir=$order(results(dir)) quit:(""=dir)  do  quit:stop
	.	if ('$data(expect(dir)))&('$data(cycles(dir))) do  quit:stop
	.	.	write "TEST-E-FAIL, No relinkctl file for dir '"_dir_"' expected.",!
	.	.	set stop=TRUE
	.	.	if $zjobexam()
	.	.	break
	.	set cycles(dir)=1
	.	set name=""
	.	for  set name=$order(results(dir,name)) quit:(""=name)  do  quit:stop
	.	.	if ('$data(expect(dir,name)))&('$data(cycles(dir,name))) do  quit:stop
	.	.	.	write "TEST-E-FAIL, No relinkctl file for file '"_dir_name_"' expected.",!
	.	.	.	set stop=TRUE
	.	.	.	if $zjobexam()
	.	.	.	break
	.	.	set cycle=$get(cycles(dir,name),0)+$get(expect(dir,name),0)
	.	.	if (cycle'=results(dir,name,"cycle")) do  quit:stop
	.	.	.	write "TEST-E-FAIL, Cycle for '"_dir_name_"' is expected to be "_cycle_" rather than "_results(dir,name,"cycle")_".",!
	.	.	.	set stop=TRUE
	.	.	.	if $zjobexam()
	.	.	.	break
	.	.	kill results(dir,name)
	.	.	set cycles(dir,name)=cycle
	.	kill results(dir)
	quit:stop

	if $data(results) do  quit
	.	write "TEST-E-FAIL, The following directories were not expected to have relinkctl files:",!
	.	zwrite results
	.	if $zjobexam()
	.	break

	if ((""'=error)&('$data(expect("error")))) do  quit
	.	write "TEST-E-FAIL, Expected no error but got one: '"_error_"'",!
	.	if $zjobexam()
	.	break

	if ((""=error)&($data(expect("error")))) do  quit
	.	write "TEST-E-FAIL, Expected an error ('"_expect("error",1)_"') but got none.",!
	.	if $zjobexam()
	.	break

	quit:((""=error)!('$data(expect("error"))))

	set fullText=$get(expect("error",1))_",%"_$get(expect("error",2))
	if (error'[fullText) do  quit
	.	write "TEST-E-FAIL, Expected error '"_fullText_"' but got '"_error_"'.",!
	.	if $zjobexam()
	.	break

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a random set of files based on the available directory and file names. Optionally, create softlinks,       ;
; unreadable directories and files, and circular references.                                                        ;
;                                                                                                                   ;
; Arguments: dirs  - List of directories to choose from.                                                            ;
;            files - List of files to choose from.                                                                  ;
;            setup - Container to populate with information about created file system configuration.                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
createRandomFiles(dirs,files,setup)
	new i,j,numOfDirs,numOfFiles,dirSparseness,dir,file,dirCreated,unreadableFiles,dir1Exists,dir2Exists,realpath,errno

	kill setup
	set numOfDirs=$length(dirs," ")
	set numOfFiles=$length(files," ")
	set unreadableFiles=$random(2)
	set (dir1Exists,dir2Exists)=FALSE

	for i=1:1:numOfDirs set dir=$piece(dirs," ",i) do:(dir'["l2")&(dir'="")
	.	set dirCreated=0
	.	if ("."=dir) set dirCreated=1
	.	else  if ($random(2)) do createDir(dir) set dirCreated=1
	.	set dirSparseness=$random(numOfFiles+1)
	.	for j=1:1:numOfFiles do
	.	.	do:($random(numOfFiles)>dirSparseness)
	.	.	.	set file=$piece(files," ",j)
	.	.	.	do writeFile(dir,file,'dirCreated)
	.	.	.	set:unreadableFiles&('$random(10))&(file'["l2") unreadableFiles(dir_"/"_file)=1
	.	.	.	do &gtmposix.realpath(dir,.realpath,.errno)
	.	.	.	set setup(realpath_"/",file)=1
	.	.	.	set dirCreated=1
	.	.	.	set:("dir1"=dir) dir1Exists=TRUE
	.	.	.	set:("dir2"=dir) dir2Exists=TRUE

	do:($random(2))
	.	do writeFile(".","l2dir1",FALSE)
	.	set setup($zdirectory,"l2dir1")=1

	; Additional file configurations to explore:
	do:($random(2))
	.	; Create circular soft link references.
	.	if $&gtmposix.symlink("dir4","dir3",.errno)
	.	if $&gtmposix.symlink("dir3","dir4",.errno)
	.	set setup($zdirectory,"dir3")=1

	do:(unreadableFiles)
	.	; Make certain files unreadable.
	.	set file=""
	.	for  set file=$order(unreadableFiles(file)) quit:(""=file)  if $&gtmposix.chmod(file,0,.errno)

	do:($random(2)&(dir1Exists!dir2Exists))
	.	; Make certain directory unreadable.
	.	if ('dir1Exists) set dir="dir2"
	.	if ('dir2Exists) set dir="dir1"
	.	if (dir1Exists&dir2Exists) set dir=$select($random(2):"dir1",1:"dir2")
	.	if $&gtmposix.chmod(dir,0,.errno)
	.	do &gtmposix.realpath(dir,.realpath,.errno)
	.	set setup(realpath_"/","unreadable")=TRUE

	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a file with the specified name in a particular directory.                                                  ;
;                                                                                                                   ;
; Arguments: dir       - Directory where to create the file.                                                        ;
;            name      - Name of the file to create.                                                                ;
;            createDir - Flag indicating whether the directory should be created first.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writeFile(dir,name,createDir)
	new file,baseName,target,pos,errno

	do:(createDir) createDir(dir)
	set baseName=$zparse(name,"NAME")
	if (baseName["l2") do
	.	set baseName=$extract(baseName,3,99)
	.	set pos=$find(baseName,"dot")
	.	set:(pos) baseName=$extract(baseName,1,pos-4)_"."_$extract(baseName,pos,99)
	.	if $&gtmposix.symlink(baseName,dir_"/"_name,.errno)
	else  do
	.	set file=dir_"/"_name
	.	open file:newversion
	.	use file
	.	close file
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a directory with the specified name.                                                                       ;
;                                                                                                                   ;
; Arguments: dir - Name of the directory to create.                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
createDir(dir)
	new errno

	if $&gtmposix.mkdir(dir,FMODE,.errno)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Populate a container with subscripted values obtain from $PIECEing the value in the node itself.                  ;
;                                                                                                                   ;
; Arguments: var - Container to populate.                                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
populate(var)
	new i

	set var(0)=$length(var," ")
	for i=1:1:var(0) set var(i)=$piece(var," ",i)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Parse a file pattern (which may have wildcards in it) to extract its directory, name, and extension.              ;
;                                                                                                                   ;
; Arguments: pattern - Pattern to parse.                                                                            ;
;            parse   - Container to populate with the results of the parsing.                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
parsePattern(pattern,parse)
	new slashPos,dotPos,pos,length

	set length=$length(pattern)
	set slashPos=0
	for  set pos=$find(pattern,"/",slashPos) quit:(0=pos)  set slashPos=pos
	set parse("dir")=$extract(pattern,0,slashPos-1)
	set dotPos=slashPos-1
	for  set pos=$find(pattern,".",dotPos) quit:(0=pos)  set dotPos=pos
	set:(slashPos-1=dotPos) dotPos=length+2
	set parse("name")=$extract(pattern,slashPos,dotPos-2)
	set parse("ext")=$extract(pattern,dotPos-1,length)
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canonicalize a path by correctly resolving '.' and '..' path modifiers, redundant '/'s, and combinations thereof. ;
;                                                                                                                   ;
; Arguments: path - Path to canonicalize.                                                                           ;
;                                                                                                                   ;
; Returns: A canonicalized path.                                                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
canonicalizePath(path)
	new i,j,newPath,char,needSlash,stop

	set newPath=""
	set needSlash=FALSE
	set stop=FALSE
	set i=0
	for  do  quit:stop
	.	set char=$extract(path,$increment(i))
	.	if (""=char) do
	.	.	set stop=TRUE
	.	else  if ("/"=char) do
	.	.	set char=$extract(path,$increment(i))
	.	.	if (""=char) do
	.	.	.	set stop=TRUE
	.	.	else  if ("/"=char) do
	.	.	.	set i=i-1
	.	.	.	set needSlash=TRUE
	.	.	else  if ("."=char) do
	.	.	.	set char=$extract(path,$increment(i))
	.	.	.	if (""=char) do
	.	.	.	.	set stop=TRUE
	.	.	.	else  if ("/"=char) do
	.	.	.	.	set i=i-1
	.	.	.	.	set needSlash=FALSE
	.	.	.	else  if ("."=char) do
	.	.	.	.	set char=$extract(path,$increment(i))
	.	.	.	.	if ((""=char)!("/"=char)) do
	.	.	.	.	.	for j=$length(newPath)-1:-1:1 quit:("/"=$extract(newPath,j))
	.	.	.	.	.	if ("/"=$extract(newPath,j)) do
	.	.	.	.	.	.	set needSlash=FALSE
	.	.	.	.	.	.	set newPath=$extract(newPath,1,j-1)
	.	.	.	.	.	else  do
	.	.	.	.	.	.	set newPath=""
	.	.	.	.	.	.	set needSlash=TRUE
	.	.	.	.	.	set i=i-1
	.	.	.	.	else  do
	.	.	.	.	.	set needSlash=FALSE
	.	.	.	.	.	set newPath=newPath_"/.."_char
	.	.	.	else  do
	.	.	.	.	set needSlash=FALSE
	.	.	.	.	set newPath=newPath_"/."_char
	.	.	else  do
	.	.	.	set needSlash=FALSE
	.	.	.	set newPath=newPath_"/"_char
	.	else  do
	.	.	set:(needSlash) newPath=newPath_"/"
	.	.	set newPath=newPath_char
	.	.	set needSlash=FALSE

	set:(""=newPath) newPath="/"

	quit newPath

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Escape all '[' and ']' characters to prevent glob() (invoked in &relink.matchFiles()) from trying to match sets   ;
; enclosed in them.                                                                                                 ;
;                                                                                                                   ;
; Arguments: path - Path to have brackets escaped.                                                                  ;
;                                                                                                                   ;
; Returns: A path with escaped brackets.                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
escapeBrackets(path)
	new i,newPath,char,hasSlash,stop

	set i=0
	set stop=FALSE
	set hasSlash=FALSE
	set newPath=""
	for  do  quit:stop
	.	set char=$extract(path,$increment(i))
	.	if (""=char) do
	.	.	set stop=TRUE
	.	else  if ("\"=char) do
	.	.	set hasSlash='hasSlash
	.	else  if (("["=char)!("]"=char)) do
	.	.	if (hasSlash) do
	.	.	.	set hasSlash=FALSE
	.	.	else  do
	.	.	.	set newPath=newPath_"\"
	.	else  if (hasSlash) do
	.	.	set hasSlash=FALSE
	.	set newPath=newPath_char
	quit newPath

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Expand all environment variables in the passed string.                                                            ;
;                                                                                                                   ;
; Arguments: string - A string that contains environment variables to expand.                                       ;
;                                                                                                                   ;
; Returns: A string with all environment variables expanded.                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
expandEnvvars(string)
	new i,pos,char,envvar

	set pos=0
	for  set pos=$find(string,"$",pos) quit:(0=pos)  do
	.	for i=pos:1:$length(string)+1 set char=$extract(string,i) quit:(""=char)!("/"=char)
	.	set envvar=$extract(string,pos,i-1)
	.	set string=$extract(string,1,pos-2)_$ztrnlnm(envvar)_$extract(string,i,$length(string))
	.	set pos=i

	quit string

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Randomize the ordering of subscripted values in the passed node.                                                  ;
;                                                                                                                   ;
; Arguments: args - A node whose subscripted values are to be randomized in order.                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randomize(args)
	new i,j,l,n,tmp

	set n=args(0)
	for i=1:1:n do
	.	set l=n-i+1
	.	set j=$random(l)+1
	.	set:(j'=l) tmp=args(l),args(l)=args(j),args(j)=tmp
	quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write the passed string into the log file.                                                                        ;
;                                                                                                                   ;
; Arguments: string - Text to write to the log file.                                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
log(string)
	use LOG
	write string,!
	use $principal
	quit
