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

; File for zroutines_wildcard-ydb974 to check error that
; happens when a glob pattern can not possibly match a file ending in .so.
; This time when the filename ends in .o
START
	w "# ydb974i.m starting. This tests setting zroutines to a glob pattern that does not end in .so.",!
	w "# In this case, the filename ends in .o.",!
	w "# We expect this to produce an error.",!
	set $zroutines="not*So.so.o"

