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

	; This module contains entry points that are serially driven by ydb840.csh and checks for LVUNDEF errors
	; Previously these used to assert fail and/or SIG-11.
	;
ydb840	;
	quit

test1	;
	write "# test1 : Test [$zatransform(x,0)] when x is undefined. Should issue LVUNDEF. Not assert fail",!
	write $zatransform(x,0)
	quit

test2	;
	write "# test2 : Test [$zatransform(x,0,2)] when x is undefined. Should issue LVUNDEF. Not SIG-11",!
	write $zatransform(x,0,2)
	quit

