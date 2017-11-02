;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See test_ci_z_halt.csh for a description of this test
;
testcizhalt1
	write "testcizhalt1: Entered - Driving ^testcizhaltA",!
	do ^testcizhaltA	; Placing this routine on the stack for now but will mod it later
	write "testcizhalt1: Back in testcizhalt1 - Test complete",!
	quit
