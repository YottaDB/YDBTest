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
	;
ydb546	; Test that Naked indicator is maintained correctly when $SELECT is used in boolean expression
	;
	write "# Run ydb557.m (is test.m test case from https://gitlab.com/YottaDB/DB/YDB/-/issues/557#description)",!
        set true=1,^true=1,^false=0
        write "Naked reference before $SELECT : Expected = ^false : Actual = ",$reference,!
        set result=1!$select(true:1&0,^true:1)
        write "Naked reference after  $SELECT : Expected = ^false : Actual = ",$reference,!
	quit

