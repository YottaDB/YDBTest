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
; See test_ci_z_halt_rc.csh for a description of this test
;

;
; Entry point that expects to return an integer value that doesn't get set due to how we exit (in most cases).
;
testcizhaltrcint(haltmethod)
	halt:(1=haltmethod)
	zhalt:(2=haltmethod) 42
	zgoto:(3=haltmethod) 0
	quit:(4=haltmethod)
	write "testcihaltrcint: Invalid value for haltmethod parameter: ",haltmethod,! hang .3 ; allow to flush
	quit 24

;
; Entry point that expects to return a string value that doesn't get set due to how we exit (in most cases).
;
testcizhaltrcstr(haltmethod)
	halt:(1=haltmethod)
	zhalt:(2=haltmethod) 42
	zgoto:(3=haltmethod) 0
	quit:(4=haltmethod)
	write "testcihaltrcstr: Invalid value for haltmethod parameter: ",haltmethod,! hang .3 ; allow to flush
	quit "24 is NOT the answer"

;
; Entry point to test whether we detect missing formallist or not with call-ins
;
testcizhaltnoargs
	write "Made it successfully to testcizhaltnoargs^",$text(+0)," but should have received FMLLSTMISSING",! hang .3
	halt

;
; Entry point to test what happens when we quit with a value when none is expected
;
testcizhaltnoretval(retint)
	quit $select(retint:43,1:"x43")
