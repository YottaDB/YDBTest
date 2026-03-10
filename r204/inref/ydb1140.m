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

ydb1140a ;
	set ^stop=0
	write $job,!
	for i=1:1 quit:^stop  do
	. set ^x(i)=i
	. hang 0.01
	quit

ydb1140b ;
	for i=1:1:3000 quit:0'=$data(^x(10))  hang 0.1
	write:0'=$data(^x(10)) "READY"
	quit

ydb1140c ;
	for i=1:1:3000 quit:0'=$data(^y)  hang 0.1
	zwrite ^y
	quit
