;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fifo	;FIFO - RECORDSIZE and WIDTH limits for FIFO devices"
	;there is a comprehensive fifo test in basic
	set $ZTRAP="do error^fifo"
	set mainlvl=$ZLEVEL
	set file="fifo.pipe"
	set FAIL="FAIL"
	set PASS="PASS"
	set quote="""",JOBPARAM=quote_file_quote
	set ^A=0
	; No reader, so open will timeout - no fifo should be created
	; Will not timeout on z/OS so omit test there
	if $zversion'["OS390" do
	. open file:(FIFO:WRITE):1
	. Set timedout='$TEST
	. If 'timedout Use $P Write "TEST-E-FAIL no fifo reader OPEN should have failed",!
	. do checkfile(file)
	set jmaxwait=0
	do ^job("fifo3^fifo",1,"JOBPARAM")
	set ^A=1
	; A reader, but writer started first and has an error - no fifo should be created
	do test(file,"FIFO:WRITE:RECORDSIZE=-1","",FAIL)
	do checkfile(file)
	set ^A=0
	do wait^job
	set ^A=1
	do ^job("fifo4^fifo",1,"JOBPARAM")
	; Wait for reader to get to its OPEN
	for i=1:1:60 quit:^A  hang 1
	; The following hang stalls the "writer" so that the "reader" (executing at fifo4) has enough time
	; to get to the point where its open is waiting for the "writer" end to open (which will be done in
	; the "test" routine).  If the "writer" starts first, then the open errors will remove the FIFO.  With
	; the "reader" starting first, the FIFO stays and the tests can run normally.
	hang 5
dotests	;;;;;
	do test(file,"FIFO:WRITE:RECORDSIZE=-1","",FAIL)
	do test(file,"FIFO:WRITE:RECORDSIZE=0","",FAIL)
	do test(file,"FIFO:WRITE:RECORDSIZE=1","",PASS)
	do test(file,"FIFO:WRITE:RECORDSIZE=32767","",PASS)
	do test(file,"FIFO:WRITE:RECORDSIZE=1048576","",PASS)
	do test(file,"FIFO:WRITE:RECORDSIZE=1048580","",FAIL)
	;;;;;
	do test(file,"FIFO:WRITE","WIDTH=-1",FAIL)
	do test(file,"FIFO:WRITE","WIDTH=0",FAIL)
	do test(file,"FIFO:WRITE","WIDTH=1",PASS)
	do test(file,"FIFO:WRITE","WIDTH=32767",PASS)
	do test(file,"FIFO:WRITE","WIDTH=1048576",PASS)
	do test(file,"FIFO:WRITE","WIDTH=1048580",FAIL)
	;;;;;
	;try writing a large record, it should not write it in one line,
	;but it should not blow up either.
	set ^A=0
	do wait^job
	do ^job("fifo2^fifo",1,"JOBPARAM")
	for i=1:1:60 quit:^A  hang 1
	open file:(FIFO:WRITE:RECORDSIZE=1048576)
	use file:WIDTH=1048576
	write $$^longstr(1048570),!
	use $PRINCIPAL
	;;;;;
	;release job'd process:
	open file:(FIFO:WRITE):60
	Set timedout='$TEST
	If timedout Use $P Write "TEST-E-FAIL 2nd OPEN for FIFO longstr timed out",! Quit
	use file
	write "QUIT"
	close file
	do wait^job
	quit
test(dev,openpar,usepar,expfail) ;
	write "---------------------------------------------",!
	write "Test: ",dev,!
	do open^io(dev,openpar,60)
	Set timedout='$TEST
	If timedout Use $P Write "TEST-E-FAIL OPEN "_openpar_" timed out!",! Quit
	do use^io(dev,usepar)
	use $PRINCIPAL
	do showdev^io(dev)
	close dev
	if "FAIL"=expfail write "TEST-E-FAIL, this test was expected to fail!",!
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
	if "FAIL"'=expfail write "TEST-E-FAIL, was not expecting an error!",!
	if "FAIL"=expfail write "TEST-I-OK, was expecting an error",!
	kill expfail	; reset expect FAIL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
fifo2(file) ;
	write "fifo2 jobid: ",$J,!
	; Let writer proceed
	set ^A=1
	open file:(FIFO:READ:RECORDSIZE=1048576):100
	Set timedout='$TEST
	If timedout Use $P Write "TEST-E-FAIL fifo2 OPEN timed out",! Quit
	set done=0
	for i=1:1:100 quit:done  do
	. use file
	. read message:40
	. set t=$T,d=$device
	. if t do
	. . if 0=$length(message) set message=d
	. . use $PRINCIPAL write "message: ",message,! set:message="QUIT" done=1
	. hang 1
	close file
	quit
fifo3(file) ;
	; Wait until writer has started
	for i=1:1:60 quit:^A  hang 1
	hang 1
	; On z/OS the write doesn't wait for the read to open so it will be gone before the open to read,
	; so omit the open there
	if $zversion'["OS390" do
	. open file:(FIFO:READ:RECORDSIZE=1048576):100
	. Set timedout='$TEST
	else  set timedout=0
	If timedout Use $P Write "TEST-E-FAIL fifo3 OPEN timed out",! Quit
	; Wait until writer has finished
	for i=1:1:60 quit:'^A  hang 1
	close file quit
fifo4(file) ;
	; Let writer proceed
	set ^A=1
	open file:(FIFO:READ:RECORDSIZE=1048576):100
	Set timedout='$TEST
	If timedout Use $P Write "TEST-E-FAIL fifo4 OPEN timed out",! Quit
	; Wait until writer has finished
	for i=1:1:60 quit:'^A  hang 1
	close file
	quit
checkfile(file)	;
	set tmpfile="tmpfile.out"
	zsystem "$gtm_tst/com/lsminusl.csh "_file_" >&! "_tmpfile
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
