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

; File for zroutines_wildcard-ydb974 to try setting zroutines with wildcards in the filename and match 1 file.
START
	w "# First, try to get a single match to ydb974la.so with pattern *974la*.so",!
	set $zroutines="*974la*.so $gtm_dist"
	w "# Running routine from library a.",!
	do START^ydb974la
