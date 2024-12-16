;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This routine is designed to cause the implicit insertion of a QUIT and generate a %GTM-W-FALLINTOFLST warning.
; This is achieved through the following conditions:
; 1. Use an argumentless DO *block* without a terminating QUIT
; 2. Follow the end of the DO immediately with a label with a formallist
embeddedrtn
	do
	. write 1
formallistrtn(a,b)
	write a_b,!
