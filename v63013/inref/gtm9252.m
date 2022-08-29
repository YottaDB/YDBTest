;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-9252 - Open the read-only help file by two processes to expose the issue on pre-V63014 builds.
; Note - this issue was fixed back in r1.20 in YottaDB along with several other read-only DB issues (see
; https://gitlab.com/YottaDB/DB/YDBTest/-/issues/446#note_1081524896).
;
; Test by:
;   1. Create two subprocesses.
;   2. Run the same ^%PEEKBYNAME() invocation that forces the help file to be opened read-only.
;   3. Then both processes exit - the last one out creates the SYSCALL error message that contains
;      mention of IPC_RMID.
;   4. Wait for subprocesses to shutdown.
;
gtm9252
	;
	; Let's get a couple processes running in parallel
	lock ^startlock,^endlock
	write "# Starting two subprocesses",!
	job child^gtm9252(1)	; First test process
	set pids(1)=$zjob
	job child^gtm9252(2)	; Second test process
	set pids(2)=$zjob
	for  quit:($get(^pids(pids(1)),0)&$get(^pids(pids(2)),0))  hang .25 ; Wait for subprocs to set ^pids to indicate ready
	; At this point both subprocesses are running so release them
	write "# Releasing subprocesses",!
	lock -^startlock
	for  quit:((""'=$get(^data(pids(1)),0))&(1'=$get(^data(pids(2)),0)))  hang .25	; Wait for subprocs to get data
	; Here, both subprocesses have stored data - time to wait for subprocess shutdown
	write "# Waiting for subprocess shutdown",!
	lock
	for  quit:((0'=$zsigproc(pids(1),0))&(0'=$zsigproc(pids(2),0)))  hang .25 ; Wait for both subprocs to exit
	quit

; Routine to actually open the DB and do the command that causes our issue (need 2 processes)
child(id)
	;
	; Save our PID to a file for the script driving us to use
	set pidfile="pid"_id_".txt"
	open pidfile:new
	use pidfile
	write $job,!
	close pidfile
	;
	set ^pids($job)=1		; Record our readiness for main routine
	lock ^startlock($job)		; Wait on this until both processes signal readiness
	set ^data($job)=$$^%PEEKBYNAME("sgmnt_data.gvstats_rec.n_dsk_write","DEFAULT")
	lock ^endlock($job)		; Wait until both are done
	quit
