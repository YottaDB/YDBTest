;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Portions Copyright (c) Fidelity National			;
; Information Services, Inc. and/or its subsidiaries.		;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lockcl	;multiple clients, one holding the lock other one is waiting on
	; waiting for lockbcl to lock ^b
	s maxtime=60,found=0,timeout=0
	f  q:(found!timeout)  d
	. s x=$zsearch("lockedbcl.out")
	. if x="" d
	.. h 5
	.. s maxtime=maxtime-5
	.. if maxtime=0 s timeout=1
	. else  s found=1
	if timeout w "TEST-E-Timeout, lockbcl timed out!",!
	w "time: ",$H,!
	l ^b:10
	w $T,!
	w "it should not have gotten the lock",!,"(at ",$H,")",!,!
	W "now tell it to let go",!,"(at ",$H,")",!
	s ^bexitnow=1
	s start=$h
	l ^b:40
	w $T,!
	s end=$h,elapsed=$$^difftime(end,start)
	w "now it should have gotten the lock",!,"(at ",$H,")",!
	w "The time it took the lock command to finish:",elapsed,!
	w "it should be as long as the lockbcl sleeps after releasing the lock (which is 5 seconds now).",!
	i elapsed>39 w "FAILED. Waited too long.",elapsed,!
	q
