;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

zunicodefifo(encoding);
	;FIFO - RECORDSIZE and WIDTH limits for FIFO devices"
	;This code is similar to unicodefifo.m, but due to the fact that an open:writeonly
	;does a successful return without a reading process the synchroniztion of the code is different
	;there is a comprehensive unicodefifo test in basic
	;If this routine is modified then a corresponding change to unicodefifo.m may be required
	set ^A=0
	set ^B=0
	set $ZTRAP="do error^zunicodefifo"
	set verbose=1 set is16=encoding["UTF-16" set isM=encoding["M"
	set mainlvl=$ZLEVEL
	set file="unicodefifo"_encoding_".pipe"
	set FAIL="FAIL"
	set PASS="PASS"
	set longstr=$$^ulongstr(1048570)
	set jobstr="unicodefifo2("""_file_""","""_encoding_"""):(output=""fifojob"_encoding_".out"""_":error=""fifojob"_encoding_".err"")"
	do test(file,"FIFO:WRITE:RECORDSIZE=-1","",FAIL)
	do checkfile(file)
	write jobstr,!
	job @jobstr
	;;;;;
	do test(file,"FIFO:WRITE:RECORDSIZE=-1","",FAIL)
	do test(file,"FIFO:WRITE:RECORDSIZE=0","",FAIL)
	if (is16) do test(file,"FIFO:WRITE:RECORDSIZE=1","",FAIL)
	if ('is16) do test(file,"FIFO:WRITE:RECORDSIZE=1","",PASS) ; RECORDSIZE=1 is not allowed in UTF-16*
	do test(file,"FIFO:WRITE:RECORDSIZE=32768","",PASS)
	do test(file,"FIFO:WRITE:RECORDSIZE=1048576","",PASS)
	do test(file,"FIFO:WRITE:RECORDSIZE=1048580","",FAIL)
	;;;;;
	do test(file,"FIFO:WRITE","WIDTH=-1",FAIL)
	if (isM) do test(file,"FIFO:WRITE","WIDTH=0",FAIL)	;Behavior for WIDTH=0 is retained for M
	if ('isM) do test(file,"FIFO:WRITE","WIDTH=0",PASS)	;WIDTH=0 is allowed in UTF-*
	if (isM) do test(file,"FIFO:WRITE","WIDTH=1",PASS)
	if ('isM) do test(file,"FIFO:WRITE","WIDTH=1",FAIL)	;WIDTH=1 not allowed in UTF-8 and UTF-16*
	do test(file,"FIFO:WRITE","WIDTH=32767",PASS)
	do test(file,"FIFO:WRITE","WIDTH=1048576",PASS)
	do test(file,"FIFO:WRITE","WIDTH=1048580",FAIL)
	;;;;;
	write !,"Now try writing a large record",!
	set $ZTRAP="do error2^zunicodefifo"
	;try writing a large record, it should not write it in one line,
	;but it should not blow up either.
	do open^io(file,"FIFO:WRITE:RECORDSIZE=1048576",encoding)
	use file:WIDTH=1048576
	;tell reader we are ready to write
	set ^B=1
	for i=1:1:900 quit:^A  hang 1
	h 5
	write longstr,!
	;;;;;
	;release job'd process:
	do open^io(file,"FIFO:WRITE",encoding,60)
	use file
	write "QUIT"
	close file
	h 10
	lock ^fifolock
	quit
test(dev,openpar,usepar,expfail) ;
	write "---------------------------------------------",!
	write "Test: ",dev,!
	do open^io(dev,openpar,encoding,60)
	do use^io(dev,usepar)
	use $PRINCIPAL
	do showdev^io(dev)
	close dev
	if "FAIL"=expfail write "FAIL, this test was expected to fail!",!
	if "PASS"=expfail write "PASS",!
	quit
error	;
	; go back to the top, and continue with the next test.
	new $ZTRAP
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	zshow "S"
	write "Will continue with the rest of the tests...",!
	if '$DATA(expfail) set expfail="NO"
	if "FAIL"'=expfail write "FAIL, was not expecting an error!",!
	if "FAIL"=expfail write "OK, was expecting an error",!
	kill expfail	; reset expect FAIL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
unicodefifo2(file,encoding) ;
	set $ZTRAP="do error2^zunicodefifo"
	write "$J:",$J,!
	write "file=",file,!
	write "encoding=",encoding,!
	lock ^fifolock
	for i=1:1:900 quit:^B  hang 1
	do open^io(file,"FIFO:READ:RECORDSIZE=1048576",encoding,100)
	set ^A=1
	for i=1:1:100 use file:WIDTH=1048576 read message:40 set t=$T use $PRINCIPAL if t write "message: ",message,! quit:message="QUIT"  h 1
	close file
	quit
checkfile(file)	;
	set tmpfile="tmpfile.out"
	zsystem "ls -l "_file_" >&! "_tmpfile
	if $ZV["OS390" zsystem "$gtm_tst/com/convert_to_gtm_chset.csh "_tmpfile_" ; chtag -tc 1208 "_tmpfile
	open tmpfile:(READONLY:REWIND)
	kill notfound
	for i=1:1 use tmpfile read line quit:$ZEOF  do
	. use $PRINCIPAL
	. if line["No such file or directory" set notfound=1
	. if line["not found" set notfound=1
	. if line["does not exist" set notfound=1
	. if $DATA(notfound) write "TEST-I-FNF, file is not found",!
	. else  write $PIECE(line," ",1),"   ",file,!
	close tmpfile:(DELETE)
	quit
error2	;
	; go back to the top, and continue with the next test.
	new $ZTRAP
	use $PRINCIPAL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	write $ZSTATUS,!
	zshow "S"
	write "Will continue with the rest of the tests...",!
	if '$DATA(expfail) set expfail="NO"
	if "FAIL"'=expfail write "FAIL, was not expecting an error!",!
	if "FAIL"=expfail write "OK, was expecting an error",!
	kill expfail	; reset expect FAIL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	halt
