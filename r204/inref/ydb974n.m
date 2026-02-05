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

; File for zroutines_wildcard-ydb974 to check what happens
; when a c shared object file matches a glob pattern.
; Currently, we add it to $zroutines, but that does not cause any errors,
START
	w "# C shared library has been created, now it is time to try adding the",!
	w "# C shared library to $zroutines and make sure that the other shared libraries run without issue.",!
	set $zroutines="ydb*.so $gtm_dist"
	w "# ZWriting $zroutines to make sure that it picked up the C library.",!
	zwrite $zroutines
	w "# Running routine from library a to make sure that no error occurs",!
	do START^ydb974la
	w "# Running routine from library b to make sure that no error occurs",!
	do START^ydb974lb
