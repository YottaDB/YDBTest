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
; This script is a part of v60002/interrupt_x_time test. The goal is to ensure that ctime(), localtime(), and
; other related function calls are protected against nesting and cannot cause hangs. We accomplish this by
; firing up short-lived MUPIP processes which a concurrent M process is trying to kill with a SIGTERM signal.
; (SIGTERM results in a syslog message, and the syslog() function internally uses the same functions as the
; aforementioned XXXtime() routines; this has been demonstrated to cause hangs before the GTM-6802 changes.)
intrptxtime
	; Ensure that the child does not start prematurely.
	kill ^pid

	; Fire off the child.
	job interrupter^intrptxtime

	; Save our own and child's pids in a file.
	zsystem "echo "_$job_" > parent_pid.outx"
	zsystem "echo "_$zjob_" > child_pid.outx"

	; Prepare the pipe and control variable.
	set quit=0
	set pipe="mupip"
	open pipe:(command="/usr/local/bin/tcsh"):10:"pipe"
	use pipe

	; Start firing off short-lived MUPIP processes.
	for i=1:1 quit:($zeof!quit)  do
	.	; Without the echo the pid of the backgrounded process would not print.
	.	write "($gtm_dist/mupip journal -extract -forward mumps.mjl >>& mupip_journal"_i_".logx & ; echo)",!
	.
	.	; Read two lines, second one being empty.
	.	read pid
	.	read tmp
	.
	.	; Extract the actual pid from the bracketed expression.
	.	set pid=$piece(pid,"] ",2)
	.
	.	; Make sure the pid is valid.
	.	if ((""=pid)!(10<$length(pid))) set quit=1 quit
	.
	.	; Let the interrupter job do work by updating the global and sleeping some.
	.	set ^pid=pid
	.	hang 0.05

	; Close the pipe and quit if we do not get killed first.
	close pipe
	use $principal
	quit

interrupter
	; Set the control variables.
	set oldpid=""
	set quit=0

	; Wait for at least one process to kill.
	for  quit:$data(^pid)

	; Start killing MUPIP processes whose pids come from ^pid.
	for  quit:quit  do
	.	; Allow 10 seconds to update the global.
	.	for i=1:1:200 set pid=^pid quit:pid'=oldpid  hang 0.05
	.
	.	; If in 10 seconds the global has not been updated, we most likely have a hang.
	.	if i=200 set quit=1
	.	else  set oldpid=pid if $zsigproc(pid,15)
	quit

