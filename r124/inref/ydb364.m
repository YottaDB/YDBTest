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

ydb364	;
	quit

start	;
	; Randomly start the child. The output of the source server shutdown command when the instance is frozen
	; should not be affected by whether a mumps process is attached to the jnlpool or not. Hence the randomness.
	set ^randstart=$random(2)
	quit:'^randstart
	set jmaxwait=0
	set ^stop=0,^child=0
	do ^job("child^ydb364",1,"""""")
	; Wait for child to open journal pool (by updating ^child) before halting
	for  quit:^child'=0  hang 0.1
	quit

stop	;
	quit:'^randstart  ; If child was not started then return immediately
	set ^stop=1
	do wait^job
	quit

child	;
	set ^child=$j
	for  quit:^stop=1  hang 0.1
	quit
