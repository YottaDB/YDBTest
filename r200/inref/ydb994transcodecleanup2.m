;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Helper M program used by r200/u_inref/ydb994.csh

ydb994transcodecleanup2
 view "TRACE":0:"^TRACE"	; to avoid %YDB-I-TRACINGON message in next line in case test framework enabled it randomly
 view "TRACE":1:"^TRACE"
 set $zinterrupt="do foo"
 set $ZTE=1
 set ^aaa=1111
 quit

