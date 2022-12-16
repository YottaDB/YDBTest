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
; Helper M program used by r136/u_inref/ydb934.csh
;
ydb934	;
	; This tests https://gitlab.com/YottaDB/DB/YDB/-/issues/934#description
	set $ztimeout="1:set x=c"
	hang 1
	;
	; This tests https://gitlab.com/YottaDB/DB/YDB/-/issues/934#note_1212917310
	; The "hang 1" had to be in the same line in that test case so we keep it the same way below.
	set $ztimeout="0:set x=c" hang 1
	;
	; Initialize "c" so we no longer see the LVUNDEF error. Or else the later "quit" command
	; will see a LVUNDEF error as well due to $ztimeout getting executed for each command.
	set c=1
	;
	quit

