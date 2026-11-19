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
; YDB#1407 : ZYENCODE must not corrupt memory when many values at one level are JSON strings that are
; canonical numbers, which ZYDECODE stores with a $CHAR(0) prefix, and a long value follows them.
;
; The object and array labels are each run in their own process by zyencode_prefix_buffer-ydb1407.csh,
; once with a local source ($zcmdline 0) and once with a global source ($zcmdline 1), since ZYENCODE
; sizes its value buffer differently for each. Without the fix, each prefixed value moved the start of
; that buffer one byte further, so the long value was written past its end and the process terminated.
;
ydb1407	;
	write "Run one label at a time. See zyencode_prefix_buffer-ydb1407.csh",!
	quit
	;
object	; 20000 prefixed values, then a long value, as the children of a JSON object
	new i,x
	for i=1:1:20000 set x(i)=$char(0)_i
	set x("b")=$justify("",1048000)
	do encode(.x,+$zcmdline)
	quit
	;
array	; 20000 prefixed values, then a long value, as the elements of a JSON array
	new i,x
	for i=0:1:19999 set x(i)=$char(0)_i
	set x(20000)=$justify("",1048000)
	do encode(.x,+$zcmdline)
	quit
	;
encode(x,gbl)	; ZYENCODE x, or a copy of it in ^x if gbl is true, then check that the JSON decodes back to x
	new json,n,y
	if gbl kill ^x merge ^x=x zyencode json=^x
	else  zyencode json=x
	write "ZYENCODE done; the JSON starts with ",$extract(json(1),1,30),!
	zydecode y=json
	set n=$$same(.x,.y)
	if n write "PASS : the decoded JSON matches the source (",n," nodes)",!
	else  write "FAIL : the decoded JSON differs from the source",!
	quit
	;
same(x,y)	; Return the number of nodes if x and y have the same subscripts and values, else 0
	new n,sub
	set n=0,sub=""
	for  set sub=$order(x(sub)) quit:""=sub  quit:'$data(y(sub))  quit:x(sub)'=y(sub)  set n=n+1
	quit:""'=sub 0
	for  set sub=$order(y(sub)) quit:""=sub  quit:'$data(x(sub))
	quit $select(""=sub:n,1:0)
