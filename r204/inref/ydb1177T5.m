;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


T5 ;
	; See naked8b in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2928117803
	; See naked8b in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2928178104
	; See naked8b in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2931493706
	; See naked8b in https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1782#note_2933909981
	set incrtrapNODISP=1
	set:REPLACE $etrap="do incrtrap^incrtrap"
	new a,b

	kill ^x set a=1,a(1)=2,*b=c,*b(1)=c,*b(2)=c,c=1
	set ^x(a,1)=2
	; REPLACE
	set ^x(a,1)=3
	zwrite ^x

	quit
