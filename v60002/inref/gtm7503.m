;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
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
gtm7503
	set timeout=300
	open "troubledproc":(shell="/bin/csh":command="setenv gtm_white_box_test_case_enable 1; setenv gtm_white_box_test_case_number 91; "_$ztrnlnm("gtm_dist")_"/mumps -direct":stderr="troublederr")::"pipe"
	use "troubledproc"
	write "set ^x=1 write ""done""",!
	for elapsed=1:1:timeout read serr quit:serr["done"
	if (elapsed=timeout) write "TEST-E-ERROR, No reponse from pipe device within "_timeout_" seconds.",! close "troubledproc" halt
	use $P
	job simpleupdate
	set pid=$zjob
	for elapsed=1:1:timeout quit:'$$^isprcalv(pid)  hang 1
	close "troubledproc"
	; Kill the child and print the error if we timed out
	if (elapsed=timeout) if $&ydbposix.signalval("SIGUSR1",.sigval)!$zsigproc(pid,sigval) write "TEST-E-ERROR, Child has been killed (SIGUSR1) because it did not quit within "_timeout_" seconds.",!
	quit

simpleupdate
	set ^x=2
	quit
