;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See test_mprof_hidden_rtn.csh for a description of this test
;
testmprofhiddenrtn1
	view "TRACE":1:"^mproftrc"
	write "testmprofhiddenrtn1: Entered - Driving ^testmprofhiddenrtnA",!
	do ^testmprofhiddenrtnA	; Placing this routine on the stack for now but will mod it later
	write "testmprofhiddenrtn1: Back in testmprofhiddenrtn1 - writing out mprof trace and exiting",!
	view "TRACE":0
	set fn="mproftrc.out"
	open fn:new
	use fn
	zwr ^mproftrc
	close fn
	;
	; Take a look at the mprofiling entry for ^mproftrc("testmprofhiddenrtnA","testmprofhiddenrtnA"). This node shows what
	; happens when M-Profiling cannot look back past the call-in base frame. In versions prior to V63002_R110, the data
	; returned in this node is quite very wrong:
	;
	;    Typical value prior to V63002_R110: "2:43:3214:3257:1295610162690"
	;
	;    Typcal value for V63002_R110:       "1:0:289:289:290"
	;
	; So we'll do a quick check on the first and last values to verify whether test fails or succeeds
	;
	set tstval=^mproftrc("testmprofhiddenrtnA","testmprofhiddenrtnA")
	set count=$zpiece(tstval,":",1)
	set elap=$zpiece(tstval,":",5)
	if (1'=count) do
	. write "testmprofhiddenrtn1: FAIL - count in node ^mproftrc(""testmprofhiddenrtnA"",""testmprofhiddenrtnA"") is wrong",!
	else  if (1000000<elap) do
	. write "testmprofhiddenrtn1: FAIL - elapsed time exceeds 1 second",!
	else  write "testmprofhiddenrtn1: PASS",!
	write "testmprofhiddenrtn1: Test complete",!
	quit
