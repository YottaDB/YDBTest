;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828	; Test no memory leaks when invalid M code is specified in $ZTIMEOUT
	;
	set $etrap="set $ecode="""""
	f i=1:1:10000 set:i=1000 start=$zrealstor do
	.  set $ztimeout="1:invalidMcode"
	set end=$zrealstor
	if start=end do
	. write "PASS : No memory leaks detected",!
	else  do
	. write "FAIL : Memory leak detected : $zrealstor at start = ",start," : $zrealstor at end = ",end,!
	quit

