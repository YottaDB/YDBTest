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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Launches a single child that does a blocking wait on a lock and then sends an INTRPT signal
gtm7525
	set jmaxwait=0
	set jdetach=1
	set jnodisp=1
	set cmdstr="lke show -wait >& jwait_queue.list"
	set ^received=0
	new sigval
	lock a
	do ^job("childlock^gtm7525",1,"""""")
	do waitgrab
	; send INTRPT to the child
	if $&ydbposix.signalval("SIGUSR1",.sigval)!$zsigproc(^childpid,sigval)
	; If child is not dead within 3 seconds, SUCCESS!
	for i=1:1:15 hang 1 quit:1=^received
	write:('^received)&(15=i) "TEST-E-FAIL: Child did not receive interrupt signal within 15 seconds."
	; Check if the child is still waiting on the lock after the interrupt
	do waitgrab
	; Release the locks and quit
	lock
	do wait^job
	quit

waitgrab
	; wait until lock a is grabbed by the child
	set found=0
	for i=1:1:300 quit:found  do
	.   hang 1
	.   zsystem cmdstr
	.   do findblockedpid
	; Did child wait on the lock?
	write:'found "TEST-E-FAIL: None of the processes locked ^a after 300 retries. See jwait_queue.list.",!
	quit

childlock
	set ^childpid=$job
	set $zinterrupt="write $job_"" received interrupt."",! set ^received=1"
	lock a
	quit

findblockedpid
	; This sets "found" local to 1 if at least 1 process is blocked on ^a.
	set file="jwait_queue.list"
	open file:(exception="if $zeof=1 quit")
	use file
	for  quit:$zeof=1  do
	.       read line
	.	if $tr(line," ")["aRequestPID" set found=1
	close file
	use $p
	quit
