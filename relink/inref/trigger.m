;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper program for the trigger test. Depending on the case, it does a SET of ^x, then waits
; for an outside signal, and either then does another SET of ^x or invokes trigger code.
sets
	new STEP,file
	set STEP=0
	set $zinterrupt="set STEP=STEP+1"
	set ^x=1
	set file="pid1.out"
	open file:newversion
	use file
	write $job,!,"DONE"
	close file
	do waitForStep(1)
	set ^x=2
	open file:append
	use file
	write "DONE2",!
	close file
	quit

setandcall
	new STEP,file
	set STEP=0
	set $zinterrupt="set STEP=STEP+1"
	set ^x=3
	set file="pid2.out"
	open file:newversion
	use file
	write $job,!,"DONE"
	close file
	do waitForStep(1)
	ztrigger ^wrtrtn
	open file:append
	use file
	write "DONE2"
	close file
	quit

waitForStep(n)
	new i,timedout
	set timedout=1
	for i=1:1:300 set:(STEP>=n) timedout=0 quit:('timedout)  hang 1
	if (timedout) write "TEST-E-FAIL, Did not advance to step "_n_" in 300 seconds.",! zhalt 1
	quit
