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
;
; Direct Mode case of the r208/tp_restart_lock-ydb1383 subtest, run by r208/u_inref/ydbfuzzdm.csh (stage 10)
;
ydb1383dm
	quit

dmzg	; A BREAK in the extrinsic of a lock name, then ZGOTO 1 and LOCK +c
	;inp:"do dmx^ydb1383"
	;inp:"zgoto 1"
	;inp:"lock +c  write ""lock +c done"",!"
	;inp:"zshow ""l"""
	;has:BREAK
	;has:lock +c done
	;has:LOCK c LEVEL=1
	;not:BADLOCKNEST
