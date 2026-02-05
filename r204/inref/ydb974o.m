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
; when you try to auto-relink a shared object file
START
	w "# Starting ydb974o.m to check the error that happens",!
	w "# when you try to auto-relink a shared object file",!
	w "# We expect this to create an error as you cannot auto-relink a shared library object file.",!
	set $zroutines="ydb974la.so* $gtm_dist"
