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
; Test for GTM-5381 - Test SIGHUP device parameter making sure we can trap it with ^C handler if enabled for $P
;
; This entry is just a stub for some M function used by this test.

;
gtm5381
	write "TEST-E-FAIL This is a stub entry - not for use",!
	quit
;
; Routine to scan a given strace output file, locate the filedescriptor used for mumps.dat and locate all the
; pwrite64() calls with that filedesciptor that are not fileheader flushes (which have a write offset of 0). Keep
; track of the write sizes and the counts for each size. At the end, output a list of the writes and their sizes.
findDBWriteSizes(file)
	new done,line,fd,valueFound,blockWriteLens,p2,p4,val,rest,$etrap,debug,pwrite64Search,len
	set debug=0
	set largestBlockWrite=0		; We look for the largest block write done in this trace
	set $etrap="use $p zwr $zstatus zshow ""*"" zhalt 1"
	; Open the input file and start reading records
	open file:readonly
	use file
	; Ignore I/O usage until we've seen a reference to "mumps.dat" in an openat() call - then fall into the
	; specific search for pwrite64() calls below.
	set done=0
	for  do  quit:done
	. read line
	. if $zeof do
	. . use $p
	. . write "TEST-E-OPENATEOF Hit EOF - Unable to locate the openat() call to open database in input strace file: ",file,!
	. . zhalt 1
	. quit:((line'["mumps.dat")!(line'["openat("))
	. ; We have the open of the DB here - find the file-descriptor value
	. set fd=$zpiece(line," = ",2)
	. if fd'=(fd+0) do
	. . use $p
	. . write "TEST-E-BADFD Could not extract the file-descriptor of the database file"
	. . zshow "*"
	. . zhalt 1
	. set done=1
	use $p
	; Now find the DB pwrite64 calls. For each, parse the call. What we are looking for is:
	;   1. first parm: file descriptor should be whatever we got as the DB file-descriptor above.
	;   2. second parm: data being written should not start with 'GDSDYN' - those calls are fileheader writes.
	;   3. fourth parm: Should be non-zero (is an offset to write a block - zero offset is fileheader write).
	;   4. The returned value is the length of the write and should be a block size multiple if fullblkwrt.
	do:debug ^sstep
	set (done,valueFound)=0
	set pwrite64Search="pwrite64("_fd_", "
	for  do  quit:done
	. use file
	. read line
	. if $zeof set done=1 quit
	. use $p
	. zwrite:debug line
	. ; Parse the line to investigate the parameters
	. set line=$zpiece(line,pwrite64Search,2)	; Pull the function name off the front
	. zwrite:debug line
	. quit:""=line			     		; Only interested in "pwrite64(3, " lines
	. set p2=$zpiece(line,", ",1)			; Second parm
	. zwrite:debug p2
	. quit:"""GDSDYN"=$zextract(p2,1,7)		; If GDSDYN, then is a header write - ignore
	. set rest=$zpiece(line,", ",3)			; Fourth parm plus return value
	. set p4=$zpiece(rest,")",1)			; Fourth parm
	. zwrite:debug rest,p4
	. quit:0=p4					; Ignore if value is 0 (for headers only)
	. set val=$zpiece(rest," = ",2)			; Value
	. set valueFound=1
	. if $increment(blockWriteLens(val))		; Increment count for this write size
	close file
	use $p
	if 'valueFound do
	. write "TEST-E-FAIL: Value for maximum DB write length not found",!
	. quit
	write !,"List of write sizes and their counts for strace file ",file,!
	write ?3,"Write Length",?18,"Count",!
	set len=""
	for  set len=$order(blockWriteLens(len)) quit:""=len  do
	. write ?3,$justify(len,12),?18,$justify(blockWriteLens(len),5),!
	quit

; Routine to scan a given GDE output file (text of GDE SHOW command) and verify the expected fullblkwrt setting
; is in place.
gdeFBWRValue(file)
	new $etrap,done,line,fbwr
	set $etrap="use $p zwr $zstatus zshow ""*"" zhalt 1"
	; Open the input file and start reading records
	open file:readonly
	use file
	; Ignore I/O usage until we've seen a reference to "mumps.dat" in an openat() call - then fall into the
	; specific search for pwrite64() calls below.
	set done=0
	for  do  quit:done
	. use file
	. read line
	. if $zeof do
	. . use $p
	. . write "TEST-E-MUMPSDAT Hit EOF - Unable to locate the segment portion of the GDE SHOW output file: ",file,!
	. . zhalt 1
	. quit:(line'["mumps.dat")
	. set done=1
	; We are now at a point in the file where we have found the start of the segment definition. Look for the 'FBWR=   '
	; string that will have our fullblkwrt setting in it. Start reading the file where we left off
	set done=0
	for  do  quit:done
	. use file
	. read line
	. if $zeof do		; Should find our record before we hit EOF
	. . use $p
	. . write "TEST-E-NOFBWR Hit EOF - Unable to locate the full block write value in input GDE SHOW file: ",file,!
	. . zhalt 1
	. set fbwr=$zpiece(line," FBWR=   ",2)
	. quit:(""=fbwr)	; loop again if FBWR not found
	. set done=1
	close file
	use $p
	write "FBWR value from 'GDE SHOW' input file (",file,") is ",fbwr,!
	quit

; Routine to scan give DSE D -F output to locate and return the FULLBLKWRT setting that is in effect for the region.
dseFBWRValue(file)
	new $etrap,done,line,fbwr
	set $etrap="use $p zwr $zstatus zshow ""*"" zhalt 1"
	; Open the input file and start reading records
	open file:readonly
	use file
	; Look through the input file looking for 'Full Block Write' (plus white space) to locate the full write block
	; setting located in the file header.
	set done=0
	for  do  quit:done
	. use file
	. read line
	. if $zeof do
	. . use $p
	. . write "TEST-E-NOFBWR Hit EOF - Unable to locate the full block write value in DSE D -F output file: ",file,!
	. . zhalt 1
	. quit:(line'["Full Block Write")
	. set done=1
	use $p
	set fbwr=$zpiece(line,"Full Block Write                 ",2)
	if (""=fbwr) do
	. write "TEST_E-NOFBWR Full Block Write has no value in DSE D -F output file: ",file,!
	. zhalt 1
	write "FBWR value from 'DSE D -F' input file (",file,") is ",fbwr,!
	quit
