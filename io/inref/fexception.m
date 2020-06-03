;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Just making sure we don't break normal disk file exception handling
;This just tests the trap for a normal file by creating it readonly and then trying to write to it
;If we want to get the "not accessible" message then create "jjjl" and chmod to 000.
FEXCEPTION
	set sd="jjjl"
	open sd:(readonly:exception="g BADOPEN")
	use sd:exception="G EOF"
	for  use sd read x use $p write x,!
EOF	if '$zeof zm +$zs
	close sd
	quit
BADOPEN
	zwrite $zstatus
	zshow "d"
	quit
