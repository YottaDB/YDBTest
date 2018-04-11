;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
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
d002285	;
	; the driver script does ZSTEP OVER thrice.
	; due to the bug described in the TR, a ZSTEP OVER used not to break because of OC_HARDRET being generated
	;
	write "---------------------------------------------------------------------------------",!
	write "You should see one YDB-I-BREAK followed by two YDB-I-BREAKZST lines in the output",!
	write "---------------------------------------------------------------------------------",!
	break
	do ^d002285a
	quit
