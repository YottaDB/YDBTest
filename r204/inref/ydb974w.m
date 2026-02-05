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

; File for zroutines_wildcard-ydb974 to test invalid syntax
; of setting $zroutines to the pattern *o.
START
	w "# Running ydb974w.m to test the syntax error of setting zroutines",!
	w "# to the glob pattern *o. This is an error as all glob patterns must end",!
	w "# in .so. Thus, we expect an error saying that.",!
	set $zroutines="*o $gtm_dist"
