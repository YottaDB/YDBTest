;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test1
	set false=0
	if (0'&($select((false?1A):0,(0'?1A):(false!0),$select(false:0,false:1,false:1,1:1):1)))
	quit

test2
	set $etrap="zwrite $zstatus  halt"
	if 0
	set false=0,true=1,result=0&$select(false:0,$test?1A:1=0,$select(true:1):1) zwrite result
	quit

test3
	set $etrap="zwrite $zstatus  halt"
	set false=0,result=0&$select(false:1&0,false:$select(false:0,1:0),1:1) zwrite result
	quit

test4
	set $etrap="zwrite $zstatus  halt"
	set false=0,result=0&($select(false?1A:0,0'?1A:false!0,$select(false:1,1:1):1)) zwrite result
	quit

test5
	set $etrap="zwrite $zstatus  halt"
	set false=0,result=0&($select(false?1A:0,0'?1A:false!0,$select(false:$$extselect(1,1,0),1:1):1)) zwrite result
	quit

test6
	set $etrap="zwrite $zstatus  halt"
	set false=0,result=0&($select(false?1A:0,0'?1A:false!0,$select(false:$$extselect(0,1,1),1:1):1)) zwrite result
	quit

test7
	set $etrap="zwrite $zstatus  halt"
	set false=0,result=0&$select(false:1&0,false:$select(false:0,1:$$extselect(1,0,1)),1:1) zwrite result
	quit

extselect(a,b,c)
	quit $select(true:a&b,false:b&c,true:c&a,1:1)

