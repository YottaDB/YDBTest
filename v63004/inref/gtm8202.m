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
	 set ^a(1)="a"
	 set ^a(2)="b"

	 set ^b(1)="1"
	 set ^b(2)="2"

	 set ^c(1)="1"
	 set ^c(2)="2"

	 TSTART
	 set ^a(3)="c"
	 set ^a(4)="d"

	 set ^c(3)="3"
	 set ^c(4)="4"
	 TCOMMIT

	 view "flush"
	 quit
