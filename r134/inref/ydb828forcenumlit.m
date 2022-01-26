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
	; error in the various binary arithmetic operations that used to get SIG-11s/GTMASSERT2 in these uses prior to YDB#828
	;
ydb828forcenumlit;
	quit

test1	;
	write "# test1 : Trying [for j=+1!@x] : Expect LVUNDEF error (not SIG-11/GTMASSERT2)"
	for j=+1!@x
	quit

test2	;
	write "# test2 : Trying [for j=+1!zl_@x] : Expect LVUNDEF error (not SIG-11/GTMASSERT2)"
	for j=+1!zl_@x
	quit

test3	;
	write "# test3 : Trying [write +$ef!^x] : Expect INVSVN error (not SIG-11/GTMASSERT2)"
	write +$ef!^x
	quit

test4	;
	write "# test4 : Trying [write +0!@(sub1)] : Expect LVUNDEF error (not SIG-11/GTMASSERT2)"
	write +0!@(sub1)
	quit

test5	;
	write "# test5 : Trying a fancy expression involving unary + : Expect no output (not SIG-11/GTMASSERT2)"
        set j=-.9 set k=+11!1111111111'=(j+($select($extract(j)="-":"-",1:"")_".5")\1)

