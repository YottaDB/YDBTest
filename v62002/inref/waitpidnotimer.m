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
; Helper script for v62002/waitpid_no_timer to OPEN a pipe and invoke an external call that
; would triggers its subsequent CLOSE by either doing a call-in to the close label or sending
; a SIGTERM to itself.
waitpidnotimer
	new PIPE1,PIPE2,line

	set PIPE1="pipe1"
	open PIPE1:(command="/usr/local/bin/tcsh")::"PIPE"
	use PIPE1
	; Make sure the pipe is usable.
	write "echo test1",!
	read line:30
	if ('$test) do
	.	write "TEST-E-FAIL, Could not read from the pipe for 30 seconds",!
	.	zhalt 1
	use $principal
	write line,!
	use PIPE1
	; The argument to the external call instructs it to do a call-in to the close label
	; to do an explicit CLOSE of the pipe.
	set status=$&waitpid.wpthco(1)
	if (0'=status) do
	.	write "TEST-E-FAIL, &waitpid.wpthco(1) returned "_status,!
	.	zhalt 2
	close PIPE1

	set PIPE2="pipe2"
	open PIPE2:(command="/usr/local/bin/tcsh")::"PIPE"
	use PIPE2
	; Make sure the pipe is usable.
	write "echo test2",!
	read line:30
	if ('$test) do
	.	write "TEST-E-FAIL, Could not read from the pipe for 30 seconds",!
	.	zhalt 3
	use $principal
	write line,!
	use PIPE2
	; The argument to the external call instructs it to do send a SIGTERM to the process
	; to trigger an implicit CLOSE of the pipe during I/O rundown.
	set status=$&waitpid.wpthco(2)
	if (0'=status) do
	.	write "TEST-E-FAIL, &waitpid.wpthco(2) returned "_status,!
	.	zhalt 4
	close PIPE2
	quit

close
	close PIPE1
	quit
