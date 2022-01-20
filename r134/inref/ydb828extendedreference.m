;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; This module contains entry points that are serially driven by ydb828.csh and checks for sig-11s
	; in the various extended reference operations that used to get sig-11s in these uses prior to YDB#828
	;
ydb828extendedreference;
	; Test extended reference using ^[expratom1,expratom2] syntax does not cause SIG-11
	quit

test1	;
	write "# test1 : Test unary NOT in gvn() use of expratom_coerce_mval() for expratom1",!
	write ^['0]x
	quit

test2	;
	write "# test2 : Test unary NOT in gvn() use of expratom_coerce_mval() for expratom2",!
	write ^[0,'1]x
	quit

test3	;
	write "# test3 : Test unary NOT in name_glvn() use of expratom_coerce_mval() for expratom1",!
	write $name(^['0]x)
	quit

test4	;
	write "# test4 : Test unary NOT in name_glvn() use of expratom_coerce_mval() for expratom1",!
	write $name(^[0,'1]x)
	quit

test5	;
	write "# test5 : Test unary NOT in lkglvn() use of expratom_coerce_mval() for expratom1",!
	lock ^['0]x
	quit

test6	;
	write "# test6 : Test unary NOT in lkglvn() use of expratom_coerce_mval() for expratom1",!
	lock ^[0,'1]x
	quit

