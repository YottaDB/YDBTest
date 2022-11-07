;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
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
gtm8121	;
	; Test that MUPIP RUNDOWN does not issue DBFLCORRP error
	; This is a helper M program used by gtm8121.csh
	quit
startbkgrnd;
	set jmaxwait=0
	set ^stop=0
	set jobid=$ztrnlnm("gtm_test_jobid")
	do ^job("child^gtm8121",1,"""""")
	for  quit:($order(^x(""),-1)>10)  hang 0.01
	; we now know at least 10 updates have been done by the child so we have some dirty buffers
	hang 1
	set ^stop=1
	for  quit:^stop=2  hang 0.01
	; now we are guaranteed the backgrounded process is in a sleep loop waiting to be killed
	quit
	;
child	;
	; Do some updates in the background and then kill self
	set ^bkgrndpid=$job
	set file="killbkgrnd.csh"
	open file:newversion
	use file
	write "kill -9 "_^bkgrndpid,!
	; Also generate command to wait for this process to die before returning from the script.
	; This is needed to avoid a "File is in use by another process" error from "mupip rundown" done in
	; a later stage in the caller. It is possible to receive this error if the process is still running
	; (seen while ASYNCIO is turned ON, most likely to finish any in-progress Direct IO writes).
	write "$gtm_tst/com/wait_for_proc_to_die.csh ",^bkgrndpid,!
	close file
	for i=1:1  quit:^stop=1  set ^x(i)=$j(i,200)  hang 0.01
	set ^stop=2
	for  quit:^stop=3  hang 1
	quit
killbkgrnd;
	zsystem "kill -9 "_^bkgrndpid
	quit
