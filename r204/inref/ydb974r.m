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

; File for zroutines_wildcard-ydb974 to test adding files a bunch of times
START
	w "# Running ydb974r.m to test adding files a bunch of times",!
	w "# As this previously caused a memory issue",!
	w "# We expect this to exit without any error.",!
	set zrostr=""
	for i=1:1:100 DO
	. set zrostr=zrostr_" 20Matches/ydb974la*.so $gtm_dist"
	. set $zroutines=zrostr
