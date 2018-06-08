;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

d002477	;
	do intrpt^d002477	; test the primary issue of MUPIP INTRPT and TPTIMEOUT interfering with each other
	do hangtest^d002477	; test a secondary VMS-only issue where TPTIMEOUT error causes HANG to stop working
	quit

intrpt  ;
	; ------------------------------------------------------------------------------------------------------
	; D9E08-002477 JOB Interrupt puts IBS servers into a non functional state and breaks outofband
	;
	; The issue is that we want to test that a long running TCOMMIT command does not reset any outofband
	; related state information that was set by a MUPIP INTRPT that came in during the TCOMMIT. The
	; objective of this test is to ensure the TCOMMIT is long running for a MUPIP INTRPT to sneak in.
	; To do that first of all we enable before-image journaling on this database. Next we spawn off
	; two threads. One of them doing SETs and the other doing only KILLs of all the SETs done by the
	; first thread. A TCOMMIT that does an M-KILL involves 2-phases and is more likely to take a long time.
	; We therefore send MUPIP INTRPTs to the second thread periodically and expect it to generate a
	; JOBEXAM dump file. Note that we need a timed TP transaction in order to reproduce this issue.
	; Having GDSCERT turned on also lengthens the commit time so that is also done.
	; ------------------------------------------------------------------------------------------------------
	set linestr="----------------------------------------------------------------------------------------------------"
	write linestr,!
	write "Test 1 : Unexpired TPTIMEOUT timer cancellation in TCOMMIT does not reset pending MUPIP INTRPT event",!
	write linestr,!
	set ^stop=0
	set jmaxwait=0
	set njobs=2
	do ^job("thread^d002477",njobs,"""""")
	; Get the pid of the second thread. This assumes knowledge of the internal implementation of job.m
	set intrptpid=^%jobwait(2)
	set maxintrpts=30
	set numintrpts=10+$random(maxintrpts-10)
	Set unix=$ZVersion'["VMS"
	; The following comment is lifted from tzintr.m as we need to do the same thing here.
	;
	; If we are doing a unix test, then we can use mupip intrpt to do the interruptions but
	; if we are on VMS, that is not an option because the ZSYSTEM we would use to invoke
	; mupip tries to do IO to the same .mjo file that this process is sending it to and can't
	; and thus creates a new .mjo file for each ZSYSTEM command and contains only the error message
	; that the file is in use by another process. Because of this, we use the $ZSIGPROC function to
	; send the interrupt. Note that with this function you can send any signal but that the signal
	; we are interested in (SIGUSR1) has different values on different platforms. On VMS, it is 16.
	;
	if unix  do
	.	zsystem "echo "_numintrpts_" > thread2.numintrpts"
	.	zsystem "echo "_intrptpid_" > thread2.pid"
	if 'unix  do
	.	zsystem "pipe write sys$output "_numintrpts_" > thread2.numintrpts"
	.	zsystem "pipe write sys$output "_intrptpid_" > thread2.pid"
	set waittime=120 ; wait for a maximum of 2 minutes for JOBEXAM file to be created before moving on to next
	; The reason why we need to wait so long is that on slow systems the TCOMMIT that is done by the interrupted process
	; could take a long time to execute since the M-kill that it is doing could be of a huge global. For it to reach the
	; next M-line could itself take more than a minute.
	set jobexami=1
	for i=1:1:numintrpts  do
	.	set iteration(intrptpid,i,"1-BEFOR")=$horolog
	.	if unix   zsystem "$gtm_dist/mupip intrpt "_intrptpid_" >& mupip_intrpt_"_i_".log"
	.	if 'unix  set iteration(intrptpid,i,"SIGPROCSTATUS")=$ZSigproc(intrptpid,16)
	.	; Wait for jobexam file to be created before sending the next MUPIP INTRPT or $ZSIGPROC
	.	set waitstatus=$$FUNC^waitforfilecreate("YDB_JOBEXAM.ZSHOW_DMP_"_intrptpid_"_"_jobexami,waittime)
	.	; If file was successfully created, wait for next file # in next iteration else wait for same file in next round
	.	set iteration(intrptpid,i,"WAITFORFILECREATESTATUS")=waitstatus
	.	set iteration(intrptpid,i,"2-DURING")=$horolog
	.	if waitstatus=0 set jobexami=jobexami+1
	.	hang 1
	.	set iteration(intrptpid,i,"3-AFTER")=$horolog
	zshow "*":^debuginfo
	set ^stop=1
	do wait^job
	quit

thread	;
	view "GDSCERT":1
        set $zmaxtptime=100
	; --------------------------------------------------
	; First thread does only SETs
	; ------------------------------
        if jobindex=1  do  quit
        .       for j=1:1 quit:^stop=1  set ^a($j(j#10000,100))=$j(j,200)
	; --------------------------------------------------
	; Second thread does only KILLs
	; ------------------------------
        if jobindex=2  do  quit
        .       for i=1:1  quit:^stop=1  do
        .       .       write "i=",i,!
        .       .       hang 1
        .       .       tstart ():serial
        .       .       kill ^a
        .       .       tcommit	 ; this tcommit should take long time for it to be likely interrupted by MUPIP INTRPT
        quit

hangtest;
	; Test that after a TPTIMEOUT error, HANG command works fine
	set linestr="----------------------------------------------------------------------------------------------------"
	write !,linestr,!
	write "Test 2 : After a TPTIMEOUT error, HANG command works fine",!
	write linestr,!
	set prehang=$horolog
	hang 5
	set posthang=$horolog
	set difftime=$$^difftime(posthang,prehang)
	if difftime'>3  do
	.	write "Test FAILED : Pre-TPTIMEOUT : hang 5 returned much before 3 seconds: pre=",prehang,"post=",posthang,!
	write "Should see TPTIMEOUT error below",!
        set $ztrap="goto incrtrap^incrtrap"
	set $zmaxtptime=3
	tstart ():serial  hang 10  tcommit
	set prehang=$horolog
	hang 5
	set posthang=$horolog
	set difftime=$$^difftime(posthang,prehang)
	if difftime'>3  do
	.	write "Test FAILED : Post-TPTIMEOUT : hang 5 returned much before 3 seconds: pre=",prehang,"post=",posthang,!
	else  write "Test PASSED : HANG command works fine even after a TPTIMEOUT event",!!
	quit
