;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See test_ci_zgoto0.csh for a description of this test
;
testcizgoto01
	write "testcizgoto01: Entered - Driving ^testcizgoto0A",!
	do ^testcizgoto0A	; Placing this routine on the stack for now but will mod it later
	write "testcizgoto01: Back in testcizgoto01 - Test complete",!
	quit
