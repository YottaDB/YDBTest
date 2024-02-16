;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtmde201378
	kill x,y s $p(y,"a",(2**20)-12)=$c(0,0)
	set x(y,12345)=5
	set z=$q(x)
	write "1MiB = ",2**20," : $zlength(z) = ",$zlength(z),!
	quit
