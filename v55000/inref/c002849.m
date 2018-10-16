;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
; Test that LOCK/HANG does not restart the timer on interrupts and that the time spent in interrupt handlers is counted towards the total
; timeout duration. The delay between interrupts allows the LOCK/HANG to spend some time actually waiting.
c002849
	new i,errno,lockTimeout,durationMs,interruptsToSend,value,line
	new WAITTIMEOUT,INTERRUPTCOUNT,INTERRUPTERPID,TVSEC1,TVSEC2,TVUSEC1,TVUSEC2,DEBUG

	set lockTimeout=20	; Timeout for the main lock.
	set interruptsToSend=4	; Interrupts to send per each main lock wait.
	set WAITTIMEOUT=60	; Timeout for waits on auxiliary locks, globals, and process termination.
	set DEBUG=0		; Flag to control debug messages.
	set testlock=$random(2)	; What command do we test? (0 - HANG; 1 - LOCK)

	set $etrap="set $etrap=""zhalt 1"",x=$zjobexam() zhalt 1"
	set $zinterrupt=""

	; Take the hit reading the external calls table now.
	if ($&ydbposix.gettimeofday(.TVSEC1,.TVUSEC1,.errno))

	write:DEBUG "Starting main process (pid "_$job_")",!

	; Acquire the interrupter lock and start the interrupter job.
	lock +^interrupterLock
	set ^interrupterQuits=0
	set ^interrupterWaits=1
	job interrupter($job,interruptsToSend,WAITTIMEOUT,DEBUG)
	set INTERRUPTERPID=$zjob

	; Wait for an indication that the interrupter job is ready.
	write:DEBUG "Waiting for interrupter value to become 0",!
	do waitForInterrupterValue(0,1)

	; Allow for three attempts to receive at least one interrupt during the main lock/hang wait. After each failed attempt the
	; lock/hang timeout multiplies to increase the chances of a timely interrupt (lockTimeout variable keeps track of this
	; duration for both HANG and LOCK commands).
	for i=1:1:3 do  quit:(INTERRUPTCOUNT)  set lockTimeout=lockTimeout*1.5
	.	set (TVSEC1,TVSEC2,TVUSEC1,TVUSEC2)=0
	.	set INTERRUPTCOUNT=0
	.	set $zinterrupt="do interrupt"
	.	; Since we do not want to send interrupts back-to-back while the main process is waiting on the lock, set the
	.	; interrupt wait time as a fraction of the lock timeout with the denominator being one more than the number of
	.	; interrupts. That leaves the interrupter with the time equalling one interrupt wait time to split among all hangs
	.	; preceding the delivery of each interrupt.
	.	set (INTERRUPTWAIT,^INTERRUPTWAIT)=lockTimeout/(interruptsToSend+1)
	.	write:DEBUG i_": Setting interrupter value to 0",!
	.	set ^interrupterWaits=0
	.	; Allow the interrupter job to start sending interrupts.
	.	write:DEBUG i_": Releasing the interrupter lock",!
	.	lock -^interrupterLock
	.	if testlock do timelock
	.	else  do timehang
	.	set $zinterrupt=""
	.	; Ensure that the interrupter job has gone through a cycle of sending interrupts.
	.	write:DEBUG i_": Waiting for interrupter value to become 1",!
	.	do waitForInterrupterValue(1,1)
	.	write:DEBUG i_": Reacquiring the interrupter lock",!
	.	lock +^interrupterLock:WAITTIMEOUT
	.	do:('$test) exit("TEST-E-FAIL, Parent timed out while waiting for ^interrupterLock to become available",1,1)

	; Signal the interrupter job to exit.
	set ^interrupterQuits=1
	set ^interrupterWaits=0
	lock -^interrupterLock

	do:(0=INTERRUPTCOUNT) exit("TEST-E-FAIL, Parent did not receive a single interrupt in three "_$select(testlock:"lock",1:"hang")_" timeouts; perhaps, due to a slow box",1,1)

	set durationMs=((TVSEC2-TVSEC1)*1E3)+((TVUSEC2-TVUSEC1)/1E3)
	; If the time spent waiting for the lock was less than the requested lock/hang timeout, error out.
	do:((1E3*lockTimeout)>durationMs) exit("TEST-E-FAIL, Total time spent while waiting for the lock ("_durationMs_"ms) is too small (<"_lockTimeout_"s)",1,1)
	; If the total lock wait time suggests that the timer was restarted upon receiving each interrupt or that the time spent in
	; interrupts was not counted towards the total lock wait, error out.
	set value=lockTimeout+(INTERRUPTCOUNT*INTERRUPTWAIT)
	do:((1E3*value)<=durationMs) exit("TEST-E-FAIL, Total time spent while waiting for the "_$select(testlock:"lock",1:"hang")_" ("_durationMs_"ms) is too high (>"_value_"s)",1,1)
	do exit("TEST-I-SUCCESS, Test succeeded",0,1)
	quit

; Interrupt handler.
interrupt
	; Do not count interrupts delivered too early or too late.
	quit:(0=TVSEC1)!(0'=TVSEC2)
	zshow "S":line
	quit:(line("S",2)'["timelock+4^c002849")&(line("S",2)'["timehang+4^c002849")
	write:DEBUG "In interrupt",!
	set INTERRUPTCOUNT=INTERRUPTCOUNT+1
	write:DEBUG "  - starting a sleep for "_INTERRUPTWAIT_" seconds",!
	hang INTERRUPTWAIT
	write:DEBUG "  - finishing the sleep",!
	quit

; Interrupter job.
interrupter(parentPid,interruptsToSend,WAITTIMEOUT,DEBUG)
	new i,j,sigusrNumber,interruptWait

	write:DEBUG "Starting interrupter process (pid "_$job_")",!
	write:DEBUG "Parent pid is "_parentPid,!
	set $etrap="set $etrap=""zhalt 1"",x=$zjobexam() zhalt 1"
	; Obtain platform-specific value for the SIGUSR1 signal.
	if $&ydbposix.signalval("SIGUSR1",.sigusrNumber)
	lock +^timedLock
	set ^interrupterWaits=0
	for i=1:1:4 do
	.	write:DEBUG i_": Waiting for interrupter value to become 0",!
	.	do waitForInterrupterValue(0,0)
	.	do:(^interrupterQuits) exit("TEST-I-INFO, Interrupted exited as instructed by the parent",0,0)
	.	write:DEBUG i_": Acquiring the interrupter lock",!
	.	lock +^interrupterLock:WAITTIMEOUT
	.	do:('$test) exit("TEST-E-FAIL, Interrupter timed out while waiting for ^interrupterLock to become available",1,0)
	.	set interruptWait=^INTERRUPTWAIT
	.	; Start sending interrupts.
	.	for j=1:1:interruptsToSend do
	.	.	hang interruptWait/(interruptsToSend+1)
	.	.	write:DEBUG i_"."_j_": Delivering an interrupt",!
	.	.	do:($zsigproc(parentPid,sigusrNumber)) exit("TEST-E-FAIL, Interrupter failed to send an interrupt to the parent because it is gone",1,0)
	.	.	hang interruptWait
	.	write:DEBUG i_": Setting interrupter value to 1",!
	.	set ^interrupterWaits=1
	.	write:DEBUG i_": Releasing the interrupter lock",!
	.	lock -^interrupterLock

	do exit("TEST-E-FAIL, Interrupter was never instructed by the parent to terminate",1,0)
	quit

; Wait for the ^interrupterWaits global to take the specified value.
waitForInterrupterValue(value,parent)
	new i,success

	set success=0
	for i=1:1:WAITTIMEOUT set:(value=^interrupterWaits) success=1 quit:(success)  hang 1
	quit:(success)
	do:(parent) exit("TEST-E-FAIL, Parent timed out while waiting for ^interrupterWaits to become "_value,1,1)
	do:('parent) exit("TEST-E-FAIL, Interrupter timed out while waiting for ^interrupterWaits to become "_value,1,0)
	quit

; Exit. If parent, wait for the interrupter job to terminate.
exit(message,status,parent)
	new i,success,dumpFile

	do:(parent)
	.	set ^interrupterQuits=1
	.	lock -^interrupterLock
	.	set success=0
	.	; Ensure the interrupter is gone.
	.	for i=1:1:WAITTIMEOUT set:($zsigproc(INTERRUPTERPID,0)) success=1 quit:(success)  hang 1
	; Do not print the original message if the parent timed out waiting for the interrupter to terminate and that changed the
	; exit status of the application.
	write:(('parent)!(status)!(success)) message,!
	if (parent&('success)) set status=1 write "TEST-E-FAIL, Parent timed out while waiting for the interrupter job to terminate",!
	do:(status)
	.	set dumpFile=$zjobexam()
	.	write "TEST-E-TEXT, See "_dumpFile_" for details",!
	hang 1
	zhalt status
	quit

timelock
	new errno
	if $&ydbposix.gettimeofday(.TVSEC1,.TVUSEC1,.errno)
	write:DEBUG i_": Got TVSEC1 ("_TVSEC1_") and TVUSEC1 ("_TVUSEC1_")",!
	lock +^timedLock:lockTimeout
	if $&ydbposix.gettimeofday(.TVSEC2,.TVUSEC2,.errno)
	write:DEBUG i_": Got TVSEC2 ("_TVSEC2_") and TVUSEC2 ("_TVUSEC2_")",!
	quit

timehang
	new errno
	if $&ydbposix.gettimeofday(.TVSEC1,.TVUSEC1,.errno)
	write:DEBUG i_": Got TVSEC1 ("_TVSEC1_") and TVUSEC1 ("_TVUSEC1_")",!
	hang lockTimeout
	if $&ydbposix.gettimeofday(.TVSEC2,.TVUSEC2,.errno)
	write:DEBUG i_": Got TVSEC2 ("_TVSEC2_") and TVUSEC2 ("_TVUSEC2_")",!
	quit
