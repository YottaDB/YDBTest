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

; File for zroutines_wildcard-ydb974 to test using [] in glob pattern
START
	w "# Running ydb974u.m to test using [] in glob pattern.",!
	w "# We expect *974l[ab].so to match both 974la.so and 974lb.so.",!
	w "# So we expect both library function to run.",!
	set $zroutines="*974l[ab].so $gtm_dist"
	w "# $zroutines set, first try ydb974la",!
	do START^ydb974la
	w "# Next try ydb974lb",!
	do START^ydb974lb
	w "# Next we will try to match a source path with a ? glob char",!
	w "# We expect this to work and appear in $zroutines.",!
	set $zroutines="?0Matches/ydb974la1.so"
	w $zroutines,!
