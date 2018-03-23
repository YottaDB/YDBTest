;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gvnincr2callin	;
	; At this point, our call-stack is
	;	ydb_tp_s -> ydb_tp_s -> ydb_ci
	; Now randomly choose to finish the needed $increment in this M frame (i.e. test TP restarts in C -> M)
	; or do it in a nested M frame which is invoked from a C frame (i.e. test TP restarts in C -> M -> C -> M)
	; where the outermost C frame is what established the TP transaction.
	;
	if '$get(nest) set nest=1+$random(8)	; do not nest more than max supported call-in depth
	if $incr(nest,-1) set x=$&c2m2c
	else  if $incr(^tp2)
	quit
