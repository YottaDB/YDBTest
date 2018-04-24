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

tprestart	;
	set ^stop=0,jmaxwait=0			; signal child processes to proceed
	do ^job("child^tprestart",5,"""""")	; start 5 jobs
	hang 10					; let child run for 10 seconds
	set ^stop=1				; signal child processes to stop
	do wait^job				; wait for child processes to die
        quit

child  ;
	for i=1:1  quit:^stop=1  do
	.	tstart ():serial
	.	set x=$incr(^c)
	.	set ^a(x)=1,^b(x)=2
	.	tcommit
	quit
