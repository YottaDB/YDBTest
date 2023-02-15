;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-9332 - Test that the rollover of pctl->ctl->wakeups incremented by mlk_wake_pending() does not
;	     cause problems in V63014 and beyond. Previously, when the value rolled over to 0, a
;	     process could be told it got a lock when it actually didn't in this situation. The current
;	     code assert fails in DBG when in this situation though with the fix in it, it never sees a
;	     zero. Still, if V63014 is modified to remove the fix (remove line 60-61 of mlk_wake_pending.c
;	     that increment pctl->ctl->wakeups if it is zero) and this routine will fail with an assert
;	     failure.
;
gtm9332
	set workerCount=2
	write "#",!
	write "# Drive ",workerCount," worker processes - we expect these to succeed on V63014 and later and",!
	write "# to fail on earlier versions. Each worker process tries to acquire a timed lock and releases",!
	write "# it in a 3-iteration loop. In each iteration it expects to get the lock so we verify that",!
	write "# $TEST is set to 1 and that LKE SHOW shows that we are the owner of the lock. The LKE SHOW",!
	write "# verification part would fail without the GTM-9332 fixes.",!
	set ^wait=1 	 ; Flag for workers to wait until all are ready
	set ^workers=0	 ; Count of initialized worker processes
	kill ^a
	;
	; Don't use the job framework as it uses locks which we are trying to very strictly control
	;
	for i=1:1:workerCount do
	. job @("worker^gtm9332(i):(output=""gtm9332_"_i_".mjo"":error=""gtm9332_"_i_".mje"")")
	. set jobs(i)=$zjob
	for  quit:(workerCount=$get(^workers,0))  hang .001	; Hang till all workers are ready to work
	set ^wait=0		       	    		; Release the workers
	;
	; Wait for all jobs to finish
	;
	for i=1:1:workerCount do
	. for  quit:(0'=$zsigproc(jobs(i),0))		; Wait for each of our JOBbed off processes to finish
	quit

;
; Routine to try to get a lock, wait for a lock, and spend a bit of time holding the lock
;
worker(indx)
	new i,loop,line,pid,pipe
	write "Worker #",indx," (pid ",$job,") started - waiting",!!
	if $increment(^workers)	     ; Bump to let main know we are alive
	for  quit:0=$get(^wait,1)  hang .001
	;
	; We've been released now so do our worker loop
	;
	for loop=1:1:3 do
	. use $p
	. write !,"# Loop #",loop,!
	. lock +^aLock:999
	. write:'$test "FAIL - $TEST is 0 coming back from the lock so locking failed!",!
	. hang .25	; A little compute time to make sure we get a waiter that has to be awakened
	. write "# Lock allegedly acquired - verify with LKE that WE have it",!
	. set pipe="cmdpipe"
	. kill line
	. open pipe:(command="$gtm_dist/lke show -all -wait":readonly)::"PIPE"
	. use pipe
	. for i=1:1  quit:$zeof  do
	. . read line(i)
	. set line(0)=i-1
	. close pipe
	. use $p
 	. for i=1:1:line(0) do
	. . if $zextract(line(i),1,6)="^aLock" do
	. . . ; We have the lock owner statement - parse it
	. . . set pid=$zpiece(line(i)," ",5)
	. . . if pid'=$job do
	. . . . write "FAIL - this lock was allegedly ours but is not - ",line(i),!
	. . . else  do
	. . . . write "PASS",!
	. . . set i=line(0)		; Force loop termination
	. lock -^aLock
	quit
