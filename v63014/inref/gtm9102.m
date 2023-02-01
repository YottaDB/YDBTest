;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; This is a helper M program for the v63014/gtm9102 subtest.
; See v63014/outref/gtm9102.txt for the flow of the test.
; And v63014/u_inref/gtm9102.csh for the various entryrefs in this M program that get invoked.

gtm9102	;
	quit

startupd;
	set jmaxwait=0
	set ^stop=0
	do ^job("update^gtm9102",1,"""""")
	quit

update	;
	for i=1:2  quit:^stop=1  set ^a=i,^b=(i+1)
	quit

stopupd	;
	set ^stop=1
	do wait^job
	quit

verify	;
	set diff=^a-^b
	set:(0>diff) diff=-diff
	if (diff'=1) write "VERIFY-E-FAIL : Difference between ^a and ^b : Expected [1] : Actual [",diff,"]",!
	else         write "VERIFY-S-PASS : Verification passed. Difference between ^a and ^b is = [1] as expected",!
	quit

