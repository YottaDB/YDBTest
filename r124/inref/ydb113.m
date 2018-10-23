;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
test	;
	write $$getncol^%LCLCOL
	quit

gen	;
	set len=$zlength($ZCMDLINE)
	set out=""
	set randlen=$random(len)+1
	for i=1:1:len  do
	.	set randcase=$random(2)
	.	if randcase=1  set char=$zconvert($zextract($ZCMDLINE,i),"U")
	.	else  set char=$zconvert($zextract($ZCMDLINE,i),"L")
	.	set out=out_char
	write out
