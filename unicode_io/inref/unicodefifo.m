;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
unicodefifo(encoding);
	;FIFO - RECORDSIZE and WIDTH limits for FIFO devices"
	;there is a comprehensive unicodefifo test in basic
	;If this routine is modified then a corresponding change to zunicodefifo.m may be required
	set ^B=0
	set $ZTRAP="do error^unicodefifo" do ^sstepgbl
	set verbose=1 set is16=encoding["UTF-16" set isM=encoding["M"
	set mainlvl=$ZLEVEL
	set file="unicodefifo"_encoding_".pipe"
	set FAIL="FAIL"
	set PASS="PASS"
	set longstr=$$^ulongstr(1048570)
	set jobstr="unicodefifo2("""_file_""","""_encoding_"""):(output=""fifojob"_encoding_".out"""_":error=""fifojob"_encoding_".err"")"
	set jobstr1="unicodefifo3("""_file_""","""_encoding_"""):(output=""fifojob1"_encoding_".out"""_":error=""fifojob1"_encoding_".err"")"
	write jobstr1,!
	set ^A=0
	job @jobstr1
	set ^A=1
	do test(file,"FIFO:WRITE:RECORDSIZE=-1","",FAIL)
	set ^A=0
	f i=1:1:900 quit:^A  hang 1
	if 0=^A write "FIFO reader unicodefifo3^unicodefifo couldn't start, exiting",! quit
	do checkfile(file)
	set ^A=0
	write jobstr,!
	job @jobstr
	for i=1:1:900 quit:^A  hang 1
	if 0=^A write "FIFO reader unicodefifo2^unicodefifo couldn't start, exiting",! quit
	hang 1
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
	set $ZTRAP="do error2^unicodefifo"
	;try writing a large record, it should not write it in one line,
	;but it should not blow up either.
	do open^io(file,"FIFO:WRITE:RECORDSIZE=1048576",encoding)
	;tell reader we are ready to write
	set ^B=1
	use file:WIDTH=1048576
	write longstr,!
	;;;;;
	;release job'd process:
	do open^io(file,"FIFO:WRITE",encoding,60)
	use file
	write "QUIT"
	close file
	for i=1:1:900 quit:2=^B  hang 1
	if 2'=^B write "Reader process is taking too long",! quit
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
	set $ZTRAP="do error2^unicodefifo"
	write "$J:",$J,!
	write "file=",file,!
	write "encoding=",encoding,!
	set ^A=1
	do open^io(file,"FIFO:READ:RECORDSIZE=1048576",encoding,100)
	; wait until actual write is ready before doing a read
	for i=1:1:900 quit:^B  hang 1
	if 0=^B write "Writer process is taking too long",! quit
	for i=1:1:100 use file:WIDTH=1048576 read message:40 set t=$T use $PRINCIPAL if t write "message: ",message,! quit:message="QUIT"  h 1
	close file
	set ^B=2
	quit
unicodefifo3(file,encoding) ;
	set $ZTRAP="do error2^unicodefifo"
	for i=1:1:900 quit:^A  hang 1
	if 0=^A write "Writer process is missing",! quit
	; make sure writer happens first so file is deleted on writer open error
	set fsize=0
	for i=1:1:900 quit:fsize  do
	. set fsize=$length($zsearch(file))
	if 'fsize write file_" not found in 900 seconds",! quit
	hang 1
	do open^io(file,"FIFO:READ:RECORDSIZE=1048576",encoding,100)
	for i=1:1:900 quit:'^A  hang 1
	if 1=^A write "Writer process is taking too long",! quit
	close file
	; we expect file to be gone before checkfile
	for i=1:1:900 quit:'fsize  do
	. set fsize=$length($zsearch(file))
	if fsize write file_" not removed in 900 seconds",! quit
	set ^A=1
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
