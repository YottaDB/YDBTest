;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This is a helper script for v60003/intrpt_timer_handler test. It initiates the creation of shared memory,
; changes permissions on the database to read-only, fires up a child process, and quits. The child process
; invokes an external program that sets a timer that kills the process.
ith
	write "Process started with write permissions.",!
	set ^x=1
	write "Changing permissions on the database file to be read-only.",!
	zsystem "chmod 444 mumps.dat"
	write "Starting a child process.",!
	job child^ith($job)
	for i=1:1:30 hang 1
	write "TEST-E-FAIL, Child did not terminate us in 30 seconds.",! quit
	quit

child(ppid)
	write "Child process with read-only rights started.",!
	set x=^x
	if $zsigproc(ppid,15)
	zsystem "echo "_$job_" > child_pid.outx"
	for i=1:1:20 quit:$zsigproc(ppid,0)  hang 1
	if (i=20) write "TEST-E-FAIL, Parent did not terminate in 20 seconds.",! quit
	do &ith.ith
	quit
