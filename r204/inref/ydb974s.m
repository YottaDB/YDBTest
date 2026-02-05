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

; File for zroutines_wildcard-ydb974 to test trying to add SRC paths
; associated with no-match glob patterns as the code path is
; a little different in this case.
START
	w "# Running ydb974s.m to test SRC paths in no match glob pattern.",!
	w "# This should give an error saying that you cannot add SRC paths to a shared object library.",!
	set $zroutines="def*no*match.so(woops)"
