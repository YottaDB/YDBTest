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

; test source
; https://gitlab.com/YottaDB/DB/YDB/-/issues/950#description
YDB950
	w "# We expect output that says error trap is reached",!
	set $zmaxtptime=1
	set $ztrap="do ztr"
	tstart ():serial
	hang 2
	tcommit
	quit
ztr
	write "Error trap reached",!
	quit
