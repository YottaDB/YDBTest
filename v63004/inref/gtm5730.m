;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gtm5730()
	for i=1:1:1000 do
	. tstart ():(serial:transaction="BATCH") ; use BATCH to avoid test slowdown due to jnl hardening for every TCOMMIT
 	. set ^x(i)=i
	. tcommit
	for i=1001:1:2000 set ^x(i)=i ;
	kill ^x
	quit
