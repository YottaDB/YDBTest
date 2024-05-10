;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

test	; Expression from:
	;   https://gitlab.com/YottaDB/DB/YDB/-/issues/698#description
	;
	set $ztrap="write ""error: "",$piece($zstatus,"","",3,4),! halt"
	write 0!($random(($select(false:1)!$select(true:1))!$random(@ifalse)))
	quit
