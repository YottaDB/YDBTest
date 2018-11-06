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
;
check	;
	VIEW "POOLLIMIT":"AREG":64
	write "DEFAULT: "_$View("POOLLIMIT","DEFAULT"),!
	write "AREG: "_$View("POOLLIMIT","AREG")
	quit

dseinp	;
	set file="dse.inp"
	open file:(newversion)
	use file
	For i=1:1:2  Do
	.	For j=0:1:32  Write "dump -block="_$$FUNC^%DH(j,2),!
