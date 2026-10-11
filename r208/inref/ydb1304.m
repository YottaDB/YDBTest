;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1304 : ZYDECODE of a local variable must accept a root node or JSON chunk node whose value is a
; number computed by an arithmetic expression, which has no string form until something forces one.
;
; Each label below is run in its own process by zydecode_numeric_values-ydb1304.csh, once with a local
; destination ($zcmdline 0) and once with a global destination ($zcmdline 1), since op_zydecode() has a
; separate branch for each. The bug showed up reliably only on the first ZYDECODE in a process, since
; op_zydecode() read whatever was left in the string fields of the numeric-only value.
;
; The values are computed from the variable i so that the compiler cannot fold them into literals,
; which carry both a string and a numeric form and so never showed the bug.
;
ydb1304	;
	write "Run one label at a time. See zydecode_numeric_values-ydb1304.csh",!
	quit
	;
root	; computed root
	new gbl,i,src
	set gbl=+$zcmdline,i=2,src=i-1,src(1)="{""a"":1}"
	do decode(.src,gbl)
	quit
	;
chunk	; computed chunk in the middle of the JSON
	new gbl,i,src
	set gbl=+$zcmdline,i=2,src=3,src(1)="[1,",src(2)=i+40,src(3)="]"
	do decode(.src,gbl)
	quit
	;
both	; computed root and computed chunk
	new gbl,i,src
	set gbl=+$zcmdline,i=2,src=i+1,src(1)="[1,",src(2)=i+40,src(3)="]"
	do decode(.src,gbl)
	quit
	;
badroot	; roots that are not a positive integer still issue ZYDECODEWRONGCNT
	new gbl,i,src
	set gbl=+$zcmdline,i=2
	set src="",src(1)="{}" do decode(.src,gbl,"root """"")
	set src=i-2,src(1)="{}" do decode(.src,gbl,"computed root 0")
	quit
	;
badchunk	; an empty, missing, or value-less chunk still issues LVUNDEF
	new gbl,src
	set gbl=+$zcmdline
	kill src set src=2,src(1)="[1",src(2)="" do decode(.src,gbl,"empty chunk")
	kill src set src=2,src(1)="[1" do decode(.src,gbl,"missing chunk")
	kill src set src=2,src(1)="[1",src(2,1)="x" do decode(.src,gbl,"chunk with no value, only a descendant")
	quit
	;
decode(src,gbl,label)
	; ZYDECODE src into the local dst, or into the global ^dst if gbl is true, then ZWRITE the
	; destination, or show the error without its routine location
	new $etrap,dst
	set $etrap="write ""ZSTATUS="",$piece($zstatus,"","",3,99),! set $ecode="""" quit"
	write:$data(label) "# ",label,!
	if 'gbl zydecode dst=src zwrite dst quit
	kill ^dst zydecode ^dst=src zwrite ^dst
	quit
