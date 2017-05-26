;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
terminal ; Test terminal I/O
test1	set $ZTRAP="do error^terminal"
	set unix=$ZVERSION'["VMS"
	set mainlvl=$ZLEVEL
	set file=$PRINCIPAL
	set infofile="zshow.outx"
	open infofile:(NEWVERSION)
	set FAIL="FAIL"
	set PASS="PASS"
	;;;;;
	;;;;; update X on each line if you add other tests in between-->;;;X
	do test(file,"","WIDTH=-1",1,FAIL)				;;;1
	do test(file,"","WIDTH=0",300,PASS)				;;;2
	do test(file,"","WIDTH=2",4,PASS)				;;;3
	do test(file,"","WIDTH=32767",100,PASS,FAIL)			;;;4
	do test(file,"","WIDTH=1048576",100,PASS,FAIL)			;;;5
	do test(file,"","WIDTH=1048580",100,PASS,FAIL)			;;;6
	;;;;;
	do test(file,"","LENGTH=-1",0,FAIL)				;;;7
	do test(file,"","(LENGTH=0:WIDTH=100)",100,PASS)		;;;8
	;;The following test should reset $Y for the long line that
	;;wraps, but it does not. Fix the reference file once the
	;;TR is fixed.
	;;:C9E02-002526 $Y does not rest if LENGTH (deviceparameter) is reached if one output line wraps
	do test(file,"","(LENGTH=2:WIDTH=30)","testlength",PASS)	;;;9
	do test(file,"","(WIDTH=30:LENGTH=255)",150,PASS)		;;;10
	do test(file,"","(LENGTH=256)",10,PASS,FAIL)			;;;11
	do test(file,"","LENGTH=32767",150,PASS,FAIL)			;;;12
	do test(file,"","LENGTH=1048576",80,PASS,FAIL)			;;;13
	do test(file,"","LENGTH=1048580",80,PASS,FAIL)			;;;14
	;;;;;
	close infofile
	quit
test2	;;;;;
	set $Y=0
	use $PRINCIPAL:LENGTH=30
	for i=1:1:32 write "$Y:",$Y,!
	write "$Y should be 1 in the above line...",!
	write "Hit any key to continue, q to quit",! read *x
	if x="q" quit
	set $Y=0
	use $PRINCIPAL:LENGTH=0
	for i=1:1:10000 write "$Y:",$Y,!
	write "$Y should be 9999 in the above line...",!
	write "Hit any key to continue",! read *x
	quit
	;;;;;
test(dev,openpar,usepar,len,expfailu,expfailv) ;
	use infofile
	if '$DATA(expfailv) set expfailv=expfailu
	if '$DATA(cnt) set cnt=0
	set cnt=cnt+1
	write "-------------------Test ",cnt,"---------------------------------------------",!
	write "Test: terminal",!
	write "USE -> ",usepar,!
	use dev:@usepar
	write cnt,"-",!
	if "testlength"=len d
	. write "what is LENGTH in effect across one write statement that spans multiple lines: ",$Y,"some more",$Y,"even more",$Y,!
	. write "what is LENGTH in effect?",$Y,"some more",$Y,"even more",$Y,!
	. write "now one at a time: $Y=",$Y,!
	. write "now one at a time: $Y=",$Y,!
	. write "now one at a time: $Y=",$Y,!
	else  d
	. write $$^longstr(len/2)," ",$Y," ",$$^longstr(len/2)," ",$Y,!
	use infofile
	zshow "D"
	if unix,"FAIL"=expfailu write "TEST-F-FAILU, this test was expected to fail!",!
	if 'unix,"FAIL"=expfailv write "TEST-F-FAILV, this test was expected to fail!",!
	quit
error	;
	; go back to the top, and continue with the next test.
	new $ZTRAP
	use infofile
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	;write "Got an error while testing: ",dev,!
	write $ZSTATUS,!
	zshow "S"
	write "Will continue with the rest of the tests...",!
	if '$DATA(expfail) set expfail="NO"
	if unix,"FAIL"'=expfailu write "TEST-E-FAILU, was not expecting an error!",!
	if 'unix,"FAIL"'=expfailv write "TEST-E-FAILV, was not expecting an error!",!
	if unix,"FAIL"=expfailu write "TEST-I-OK, was expecting an error",!
	if 'unix,"FAIL"=expfailv write "TEST-I-OK, was expecting an error",!
	kill expfail	; reset expect FAIL
	write "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",!
	zgoto mainlvl
	quit
; This test was executed as an XCMD command but we needed interaction with the M routine
; to ensure that all output from the routine made it to the file. Without the interaction,
; expect seemed to exit prematurely or issue a "spawn id expNNN" error. In both cases, the
; output file size was not uniform across all hosts.
test7
	set $ETRAP="if '$zjobexam() set $ecode="""" zhalt +$zstatus"
	; The long line should not wrap
	use $principal:(NOWRAP)
	read "START",x,!
	write $$^longstr(35000),!
	read "DONE",x,!
	quit
