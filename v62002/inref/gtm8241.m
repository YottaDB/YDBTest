;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8241	;
	;
	; Test that processes blocking on a lock do not attempt to get crit on the db (thereby not creating crit contention)
	; If invoked using "mumps -run gtm8241 1" implies kill lock-holder process.
	;
	set ^proceed=0
	set jnolock=1,jnodisp=1,jmaxwait=0,^njobs=10
	do ^job("child^gtm8241",^njobs,"""""")
	lock +^parent	; hold LOCK that jobbed off children need to test whether they do frequent grab_crits or not
	set ^proceed=1	; release children so they try to LOCK
	do ^waitlkeshow(^njobs) ; wait until all children are blocking on this lock
	;
	set critstats1=$view("PROBECRIT","DEFAULT")	; take crit stats now that every child is waiting
	hang 1
	if +$zcmdline=1 zsy "kill -9 "_$j
	hang 4						; sleep 4 more seconds (a total of 5) while holding the lock
	set critstats2=$view("PROBECRIT","DEFAULT")	; take crit stats again while still holding the lock
	;
	lock -^parent	; release lock so children proceed
	do wait^job	; wait for all children to die
	;
	; Verify that blocked processes did not try to acquire crit while the holder pid is still alive
	set cat1=$piece($piece(critstats1,"CAT:",2),",",1)
	set cat2=$piece($piece(critstats2,"CAT:",2),",",1)
	; cat2-cat1 is the # of successful crit obtains across all processes.
	; We do not expect this to be more than a couple (just in case the current process has timers etc. that get crit).
	; That is, we expect the average crit obtains per blocked process to be close to 0. Check for that.
	; Need to do a /2 since every CAT stat is incremented per grab_crit and rel_crit which together comprise one crit attempt.
	set cat=(cat2-cat1)/^njobs/2
	if cat>0.1  do
	. write "test1 : Test FAIL : Average # of crit attempts per blocked process = ",cat," : Expecting it to be < 0.1",!
	. zshow "*":^log(1)	; record local variable state in a global for debugging purposes
	. halt
	else  write "test1 : Test PASS",!
	quit

child	;
	for  quit:^proceed=1  hang 0.1
	set ^waitstart(jobindex)=$h
	lock +^parent(jobindex)
	set ^acquired(jobindex)=$h
	quit

verify	; invoked by the shell to see how processes reacted when we killed the lock holder
	do wait^job
	set difftotal=0
	for i=1:1:^njobs  do
	. set starttime=^waitstart(i),endtime=^acquired(i),difftime=$$^difftime(endtime,starttime)
	. if $incr(difftotal,difftime)
	set avgdifftime=difftime/^njobs
	if (avgdifftime>2) do
	. write "test2 : Test FAIL : Took ",avgdifftime," seconds to get lock after holding process died. Expected ~ 1",!
	. zsh "*":^log(2)	; record local variable state in a global for debugging purposes
	else  write "test2 : Test PASS",!
	quit

