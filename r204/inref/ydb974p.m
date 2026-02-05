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

; File for zroutines_wildcard-ydb974 to test what happens when a directory has an '*' in its name
START
	W "# started ydb974p.m to test a wildcard ",!
	W "# filename with an * in the middle of its name",!
	w "# setting zroutines should not produce an error in this case.",!
	set $zroutines="ydb9*74la.so $gtm_dist"
	w "# As the name matched an exact file, $zroutines the `*` should not be treated as a wildcard",!
	w "# meaning that $zroutines should not have ydb974la.so",!
	w $zroutines,!
