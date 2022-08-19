;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-8838 - Demonstrate that the new WFR, BUS and BTS statistics are accessible via $VIEW and ^%YGBLSTAT and
; that their newly renamed counterpart fields in gvstats_rec_t (stored in a few different places depending on sharing
; options) are available via MUPIP DUMPFHEAD and ^%PEEKBYNAME(). Also, for each var in gvstats_rec_t (each of which is
; associated with a 3 char abbreviation in $VIEW("GVSTAT"), set a known value into the counter field and then fetch it
; with MUPIP DUMPFHEAD and ^%PEEKBYNAME() and validate it.
;
; This second part was rather tricky. We had to add a new whitebox case to set all of the counter fields in the
; gvstats_rec_t record that is in node_local. This is because when the process opens a DB that is not currently open
; by any other process, when it creates the node_local shared memory segment, it copies the stats from the fileheader
; to node_local. All operations to the stats then reference the node_local version. When the file is run down or when
; the fileheader is flushed by fileheader_sync(), these stats are copied back from node_local to the fileheader before
; it is flushed. The VerifyGVSTATS entry point in this routine does the validation of this.
;
	write "# This routine (",$text(+0),") should only be entered at one of the entry points. The main routine is not an entry point.",!
	zhalt 1
;
; Verify that the new statistics above are available via $VIEW("GVSTAT",reg)
VerifyView
	set stats=$view("GVSTAT","DEFAULT")
	do FindNewStats(stats,"$VIEW(""GVSTAT"")")
      	quit

;
; Verify that the new statistics are available via ^%YGBLSTAT
VerifyYGBLSTAT
	write "# Doing a few SETs to generate some statistics for ^%YGBLSTAT",!
	view "STATSHARE":"DEFAULT"				; Enable stat sharing
	for i=1:1:10 set ^a(i)=$justify(i,100)
	set stats=$$STAT^%YGBLSTAT($job)
	do FindNewStats(stats,"^%YGBLSTAT")
	quit

;
; Find new stats starting with WFR in given line
FindNewStats(statline,origin)
	new srchstr
	set srchstr=",WFR:"
	set idx=$find(statline,srchstr)-$zlength(srchstr)+1	; +1 to get past starting comma
	write "New ",origin," Statistics: ",$zextract(stats,idx,99999) ; Print rest of the string
	quit

;
; Verify that the stat names in tab_gvstats_rec.h are correct by first forking off a JOB to do a VIEW "DWB" command in
; another process so it will exit and flush the changes made to node_local into sgmnt_data where other processes will
; pick them up and be able to see them.
VerifyGVSTATS
	new $etrap
	set $etrap="use $p zwrite $zstatus write !! zshow ""*"" zhalt 1"
	; First thing to do is to learn the names of the fields in the sgmnt_data flavor of the GVSTATS array.
	; Drive ^GTMDefinedTypesInit to initialize ALL of the fields, copy what we need, then get rid of the rest.
	do Init^GTMDefinedTypesInit
	merge lclTypes=gtmtypes("gvstats_rec_t")		; Make a copy of the sub-struct we need
	kill gtmtypes,gtmtypfldindx,gtmstructs,gtmunions	; Have everything we need now so kill the large arrays
	;
	; Drive the WBTST_YDB_SETSTATSOFF white box case via the VIEW "DWB" command (drive white box) which wil set
	; our counters to the value of their offsets within the gvstats_rec_t structure. Note this is done in a job'd
	; off process as we do not want THIS process to have the DB open so this work must happen in another process
	; so it flushes to the fileheader where we can see it.
	job @("SetStats^"_$text(+0))
	set statJob=$zjob
	;
	; Now wait for the process to go away so it has done its thing
	for  quit:0'=$zsigproc(statJob,0)  hang 0.25
	;
	; Now the value is changed - fetch it via both ^%PEEKBYNAME and via MUPIP DUMPFHEAD
	;
	; First thing to do is create the MUPIP DUMPFHEAD
	zsystem "$gtm_dist/mupip dumpfhead -region DEFAULT >& mupip_dumpfhead_changed.txt"
	if 0'=$zsystem do
	. write "The MUPIP DUMPFHEAD command failed with return code ",$zsystem,!!
	. zshow "*"
	. zhalt 1
	;
	; Read the file in so we have the values to compare - only keep records containing "gvstats_rec" into the 'record()' array
	set inFile="mupip_dumpfhead_changed.txt"
	open inFile:readonly
	for  use inFile read line quit:$zeof  do
	. quit:line'["sgmnt_data.gvstats_rec."
	. set fldName=$zpiece(line,".",3)			; Isolating field name
	. set fldName=$zpiece(fldName,"""",1)
	. set fldValue=$zpiece(line,"=",2)			; Isolating value
	. set fldValue=$zpiece(fldValue,"""",2)
	. ;
	. ; Save each of these values stored as decimal instead of hex
	. set fldValue=$$FUNC^%HD(fldValue)
	. ;
	. ; Save in dfhead array
	. set dfhead(fldName)=fldValue
	use $p
	close inFile
	;
	; Now go through each of the types again verifying their ^%PEEKBYNAME and DUMPFHEAD values
	for idx=1:1:lclTypes(0) do
	. set fldName=$zpiece(lclTypes(idx,"name"),".",2)
	. ;
	. ; First %PEEKBYNAME
	. set peekValue=$$^%PEEKBYNAME("sgmnt_data.gvstats_rec."_fldName,"DEFAULT")
	. set:("0x"=$zextract(peekValue,1,2)) peekValue=$$FUNC^%HD(peekValue)
	. ;
	. ; Validate value
	. set peekExpectedValue=lclTypes(idx,"off")
	. if peekValue'=peekExpectedValue do
	. . write !,"%PEEKBYNAME() fetch for field ",fldName," expected to have the value ",peekExpectedValue," but instead has the value ",peekValue,!!
	. . zshow "*"
	. . zhalt 1
	. ;
	. ; Now check the DUMPFHEAD value we loaded above
	. set verifyOffset=lclTypes(idx,"off")
	. if dfhead(fldName)'=verifyOffset do
	. . write !,"sgmnt_data.gvstats_rec.",fldName," expected to have the value ",verifyOffset," but instead has the value ",dfhead(fldName),!!
	. . zshow "*"
	. . zhalt 1
	;
	; All done!
	write "The gvstats record fields were validated",!
	quit

;
; This routine is driven in a JOB statement. This routine drives any white box tests enabled for it which in this case drives
; the WBTEST_YDB_SETSTATSOFF white box code which sets all of the counters in node_local.gvstats_rec (which are the counters
; that matter when a DB is open). The value each field is set to is equal to its offset in the gvstats_rec_t structure.
;
SetStats
	view "DWB":"DEFAULT"
	quit
