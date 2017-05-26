;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jnoview(jobcmd);
	Job @jobcmd
	Write jobcmd," GTM_TEST_DEBUGINFO: ",$ZJOB,!
	quit
hworld;
	write "Hello World "_$job,!
	quit
jnoview1(jobcmd,needed);
	;
	; If timeout is not specified $TEST should be unaffected.
	;
	set before=$TEST
	job @jobcmd
	set after=$TEST
	if needed do
	. if after'=1 write "Timeout specified and $TEST is not set",!
	else  do
	. if before'=after write "Timeout is not specified and $TEST changed",!
	Write jobcmd," GTM_TEST_DEBUGINFO: ",$ZJOB,!
	quit
; This label verifis that JOB command handles entryref with input argument properly.
; Hence dummy(not so useful) parameters are passed to the label.
timehworld(needed,timeout);
	write "Hello World "_$job,!
	write "Timeout = "_timeout,!
	write "Timeout specified ="_$get(needed),!
	quit
