;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ydb737ci	;YDB#737 Call-in APIs don't know how to handle $quit
1(var)		;
	new $etrap,$estack set $etrap="quit:$estack  set $etrap=""write $zstatus,! halt"",$ec="""" quit:$quit +$zstatus"
	xecute var
	quit:$quit 5 quit
