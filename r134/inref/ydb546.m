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
;
	; This module contains entry points that are serially driven by ydb546.csh.
	; These used to GTMASSERT2 prior to YDB#546.
	;
ydb546	; Test that Nested $SELECT() functions do not issue incorrect GTMASSERT2 or LVUNDEF error
	;
	quit

test1	;
	write "## test1 : Tests z.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#description",!
	write "## Expect output of 1",!
        set false=0
        set result=(0'&($select((false?1A):0,(0'?1A):(false!0),$select(false:0,false:1,false:1,1:1):1))) zwrite result
	quit

test2	;
	write "## test2 : Tests v.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#description",!
	write "## Expect output of 1",!
        set false=0
        set result=(false!($select(false:(1&0),false:($select(false:false,1:false)),1:1))) zwrite result
	quit

test3	;
	write "## test3 : Tests z1.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        set true=1,false=0,result=0&$select(false:0&1,$select(true:1):1) zwrite result
	quit

test4	;
	write "## test4 : Tests z2.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        set false=0,true=1,result=0&$select(false:0&$test,1&$select(true:1):0) zwrite result
	quit

test5	;
	write "## test5 : Tests z3.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        set false=0,true=1,result=0&$select(false:$test&0,1&$select(true:1):0) zwrite result
	quit

test6	;
	write "## test6 : Tests z4.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        if 0
        set false=0,true=1,result=0&$select(false:0,$test?1A:1=0,$select(true:1):1) zwrite result
	quit

test7	;
	write "## test7 : Tests z5.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        set false=0,result=0&$select(false:1&0,false:$select(false:0,1:0),1:1) zwrite result
	quit

test8	;
	write "## test8 : Tests z6.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299108731",!
	write "## Expect output of 0",!
        set $etrap="zwrite $zstatus  halt"
        set false=0,result=0&($select(false?1A:0,0'?1A:false!0,$select(false:1,1:1):1)) zwrite result
	quit

test9	;
	write "## test9 : Tests booltest.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299129926",!
	do ^ydb546booltest
	quit
