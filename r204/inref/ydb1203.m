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

ydb1203 ;
	set max=+$zcmdline
	for i=0:1:max write " set x",$translate($justify(i,4)," ",0),"=""""",!
	; REPLACEwrite " new",!
	set i=$translate($justify(i+1,4)," ",0)
	write " set x",i,"=""""",!
	write " zwrite x",i,!
	quit
