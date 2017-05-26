;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8190
	set ^end=0
	; Not using the job.m framework because ^%jobwait global causes conflicts within the framework itself
	set ^a(1)=0,^b(2)=0,^c(3)=0
	job child^gtm8190:(error="child.mje1":output="child.mjo1")
	set pid1=$zjob
	job child^gtm8190:(error="child.mje2":output="child.mjo2")
	set pid2=$zjob
	job child^gtm8190:(error="child.mje3":output="child.mjo3")
	set pid3=$zjob
	set file="waitpidstodie.m"
	open file
	use file
	write "    set ^end=1 for i="_pid1_","_pid2_","_pid3_" do ^waitforproctodie(i,300)",!
	close file
	; pids.txt is used to provide the regex needed by a grep
	set file="pids.txt"
	open file
	use file
	write "("_pid1_"|"_pid2_"|"_pid3_").*NONTPRESTART"
	close file
	quit

; Carried all global operations below to decrease chance of having consecutive repeated messages. The idea is to have different line
; numbers in the conflicted globals. The following should ensure that each process has a different label and a good chance of having
; the conflict in different lines within the function
child(jobindex)
	if $ztrnlnm("useviewcommand") view "LOGNONTP"
	else  if $ztrnlnm("gtm_nontprestart_log_delta")'=$view("LOGNONTP") write "TEST-E-FAIL $VIEW does not match env var",! halt
	for i=1:1 do ^setglobals  quit:^end
	quit

; Lightweight wait in order to prevent expensive getoper.csh
waitrestartaction
	set timeout=60
	set tdelta=0.5 ; the wait duration between PEEKBYNAME checks
	set timecnt=timeout/tdelta
	for i=1:1:timecnt quit:$$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_0","DEFAULT")  hang tdelta
	write:i=timecnt "TEST-E-FAIL No retries occurred in "_(timeout)_" seconds",!
	set ^end=1
	quit
