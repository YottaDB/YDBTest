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
gtm8202()
	 set ^a(1)="10"
	 set ^a(2)="20"

	 set ^b(1)="5"
	 set ^b(2)="10"

	 set ^c(1)="3"
	 set ^c(2)="6"

	 TSTART
	 set ^a(3)="30"
	 set ^a(4)="40"

	 set ^b(3)="15"
	 set ^b(4)="20"

	 set ^c(3)="9"
	 set ^c(4)="12"
	 TCOMMIT

	 view "flush"
	 quit
