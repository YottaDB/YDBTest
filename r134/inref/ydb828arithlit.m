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

	; This module contains entry points that are serially driven by ydb828.csh and checks for expected runtime
	; error in the various binary arithmetic operations that used to get sig-11s in these uses prior to YDB#828
	;
ydb828arithlit;
	quit

test1	;
	write "# test1 : Test compile-time NUMOFLOW error in op_add() while inside FOR loop",!
	for  set x=5E46+5E46
	quit

test2	;
	write "# test2 : Test compile-time NUMOFLOW error in op_sub() while inside FOR loop",!
	for  set x=-5E46-5E46
	quit

test3	;
	write "# test3 : Test compile-time NUMOFLOW error in op_mul() while inside FOR loop",!
	for  set x=1E24*1E24
	quit

test4	;
	write "# test4 : Test compile-time DIVZERO error in op_div() while inside FOR loop",!
	write "#         Note that this test did not SIG-11 previously but is added for completeness",!
	for  set x=1/0
	quit

test5	;
	write "# test5 : Test compile-time NUMOFLOW error in op_div() while inside FOR loop",!
	for  set x=1E24/1E-24
	quit

test6	;
	write "# test6 : Test compile-time DIVZERO error in op_idiv() while inside FOR loop",!
	write "#         Note that this test did not SIG-11 previously but is added for completeness",!
	for  set x=1\0
	quit

test7	;
	write "# test7 : Test compile-time NUMOFLOW error in op_idiv() while inside FOR loop",!
	for  set x=1E24\1E-24
	quit

test8	;
	write "# test8 : Test compile-time DIVZERO error in flt_mod() while inside FOR loop",!
	write "#         Note that this test did not SIG-11 in GT.M V7.0-001",!
	for  set x=1#0
	quit

test9	;
	write "# test9 : Test compile-time NUMOFLOW error in flt_mod() -> op_div() while inside FOR loop",!
	for  set x=1E24#1E-24
	quit

test10	;
	write "# test10 : Test compile-time DIVZERO error in op_exp() while inside FOR loop",!
	write "#         Note that this test did not SIG-11 in GT.M V7.0-001",!
	for  set x=0**-2
	quit

test11	;
	write "# test11 : Test compile-time NUMOFLOW error in op_exp() -> op_mul() while inside FOR loop",!
	for  set x=10**47
	quit

test12	;
	write "# test12 : Test compile-time NEGFRACPWR error in op_exp() while inside FOR loop",!
	for  set x=-1**-0.5
	quit

