;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test    ;
	set ^ready=0
	job child
	; Wait for child to be in a position to receive SIGUSR1 signal. Not waiting can cause the child process
	; to not yet have established its SIGUSR1 signal handler resulting in the process terminating on the
	; very first signal which would defeat the purpose of the test (to send a lot of SIGUSR1s).
	for  quit:^ready=1  hang 0.001
	for i=1:1 quit:$zsigproc($zjob,"SIGUSR1")  hang 0.001
	do ^waitforproctodie($zjob,300)
	quit

child   ;
	; The performance part of this test is disabled for both pro and dbg on single CPU machines
	; and for dbg on ARM as it has failed in the past due to slowness.
	set ^ready=1
	set perfdisabled=$ztrnlnm("gtm_test_singlecpu")
	set:(("dbg"=$ztrnlnm("tst_image"))&("HOST_LINUX_ARMVXL"=$ztrnlnm("gtm_test_os_machtype"))) perfdisabled=1
	set $zinterrupt="if $increment(intrptcnt)"
	set:(0=perfdisabled) starttime=$zut
	for i=1:1:10000  set hangtime(i)=$select(i#2:0.0001,1:0.001) hang hangtime(i)
	if 0=perfdisabled do
	.	set endtime=$zut
	.	set totalhangtime=0
	.	for i=1:1:10000 set totalhangtime=totalhangtime+hangtime(i)
	.	set totaltime=endtime-starttime
	.	set totaltime=totaltime/1000000 ; convert from nanoseconds to seconds
	.	set maxtime=totalhangtime*2
	.	if totaltime>maxtime do
	.	.	write "Hang test failed. The test took ",totaltime
	.	.	write " seconds which was more than twice the total hangtime of ",totalhangtime,!
	.	else  write "Hang test finished successfully",!
	else  write "Hang test finished successfully",!
	quit

