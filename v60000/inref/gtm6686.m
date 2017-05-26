;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This test verifies that under-construction util_out buffer is no longer exposed to corruption from
; timer pops when the handler is also exercising util_out logic.
gtm6686
	; set the switch for termination to 'off'
	set ^quit=0
	;
	; save our own pid in a file
	zsystem "echo "_$job_" > pid.outx"
	;
	; invoke the white-box test logic that starts a timer
	; printing fairly frequent syslog messages
	hang 0.999
	;
	; keep printing a particular error message without raising
	; an actual error until the termination is triggered
	for i=1:1 quit:^quit  zmessage 150382955	; simulate a SETEXTRENV info (not error)
	;
	; save the number of iterations completed in a file
	zsystem "echo "_(i-1)_" > iterations.outx"
	;
	quit
