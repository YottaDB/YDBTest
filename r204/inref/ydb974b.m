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

; File for zroutines_wildcard-ydb974 to test matching 2 shared library files with a wildcard.
START
	w "# Try to match 2 files, ydb974la.so and ydb974lb.so, with pattern *974l*.so",!
	set $zroutines="*974l*.so $gtm_dist"
	w "# Running routine from library a",!
	do START^ydb974la
	w "# Running routine from library b",!
	do START^ydb974lb
	w "# Now printing out the order of $zroutines to make sure that",!
	w "# all the shared libraries come before the $gtm_dist as that is",!
	w "# required. The shared libraries that match the same glob pattern may",!
	w "# appear in any order",!
	w $zroutines,!
	w "# Testing to ensure that we cannot run shared library d.",!
	w "# We should not be able to run this as the filename is",!
	w "# ydb974la.so.golf, so it should not match our pattern.",!
	do START^ydb974ld
