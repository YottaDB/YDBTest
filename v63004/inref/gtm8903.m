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
gtm8903
	;We'll set some local and global variables to reference later
	SET x=1
	SET ^x=2

	;$S[ELECT](tvexpr:expr[,...])
	SET xstr="WRITE 0!$SELECT(1:x&x,1:^x),!"
	WRITE xstr,!
	XECUTE xstr

	quit
