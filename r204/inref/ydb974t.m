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

; File for zroutines_wildcard-ydb974 to test using ? in glob pattern
START
	w "# Running ydb974t.m to test using ? in glob pattern.",!
	w "# We expect *974l?.so to match both 974la.so and 974lb.so.",!
	w "# So we expect both library function to run.",!
	set $zroutines="*974l?.so $gtm_dist"
	w "# $zroutines set, first try ydb974la",!
	do START^ydb974la
	w "# Next try ydb974lb",!
	do START^ydb974lb

