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
ydb555	; Test that $SELECT with global references in a boolean expression does not GTMASSERT2
	;
	write "## Test https://gitlab.com/YottaDB/DB/YDB/-/issues/555#description",!
	write "## Expect output of 1",!
        set false=0,^true=1
        write 1!$select(false:1&0,^true:1),!
	;
	write "## Test https://gitlab.com/YottaDB/DB/YDB/-/issues/555#note_303122367",!
	write "## Expect output of 1",!
	set false=0,^true(1,2)=1
	write 0!$select(false:1&0,^true(1,2):1),!
	quit

