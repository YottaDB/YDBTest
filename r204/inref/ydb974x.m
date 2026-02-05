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

; File for zroutines_wildcard-ydb974 to test using glob patterns in a filepath
START
	w "# Running ydb974x.m to test including glob characters",!
	w "# in a filepath, we expect the glob characters to work and the library to be run",!
	set $zroutines="2?Matches/ydb974la1.so $dirPathEnv/ydb974la1.so $gtm_dist"
	do START^ydb974la
	w "# Now we test that the value of $zroutines is displayed correctly",!
	w "# We expect $dirPathEnv/ydb974la1.so to be a direct path in output",!
	w "# as it contains an environment variable.",!
	w $zroutines,!
