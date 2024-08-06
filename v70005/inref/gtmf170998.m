;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

logsome	; Log some text
	;
	set msg=$zcmdline
	if $length(msg)<2 set msg="MUMPS is alive"
	;
	set ec(0)="0 - logging is not enabled"
	set ec(1)="1 - successful logging"
	set ec(9)="error - logging is not working"
	;
	set $etrap="set st=$zstatus goto result"
	write "result: "
	set r=$zauditlog(msg)
	set st=$zstatus
	;
result	; print result
	;
	write ec(r)
	if (st'="")&((r=9)!(r=0)) write " - ",$piece(st,",",3)
	write !
	halt
