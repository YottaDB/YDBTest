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
; YDB#1317 : $QUERY() of a local whose last subscript is the empty string returns the same node after an earlier
; $QUERY() of that local returned another node whose last subscript is the empty string, and still continues a
; $QUERY() loop from the node that the previous $QUERY() returned. The stages that use reverse $QUERY(), which only
; YottaDB has, are in ydb1317rev.m, so that this routine also compiles with GT.M.

gtmfwd	; Forward $QUERY() with GT.M null collation
	new y,b,q
	set y("aa","")=1,y("b","")=2,y("b",5)=3,b(1)=1
	set q=$query(b(1))
	do check($query(y("b","")),"y(""b"",5)","$query(y(""b"","""")) after $query(b(1)) of another variable")
	set q=$query(y("aa"))
	do check($query(y("b","")),"y(""b"",5)","$query(y(""b"","""")) right after a $query() that returned y(""aa"","""")")
	set q=$query(y("b",5))
	do check($query(y("b","")),"","$query(y(""b"","""")) right after a $query() that returned y(""b"","""")")
	quit

check(actual,expected,what)
	if actual=expected write "PASS : ",what," is ",actual,!
	else  write "WRONG : ",what," is ",actual," but expected ",expected,!
	quit
