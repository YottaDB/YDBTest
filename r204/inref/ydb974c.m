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

; File for zroutines_wildcard-ydb974 to test a glob pattern with an absolute file path.
START
	set workingDir=$ZDIRECTORY
	w "# Try to match ydb974la.so and ydb974lb.so using the full path with pattern path/*974l*.so",!
	; Note, workingDir includes trailing '/'.
	set $zroutines=workingDir_"*974l*.so $gtm_dist"
	w "# Running routine from library a",!
	do START^ydb974la
	w "# Running routine from library b",!
	do START^ydb974lb
