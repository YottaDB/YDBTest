;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
launchjobs
	set jdetach=1
	set jmaxwait=0
	set ^numjobs=20
	set ^index=0
	do ^job("updateandwait^gtm7804",^numjobs,"""""")
	quit

updateandwait
	set $zinterrupt="halt"
	lock ^a($job)
	tstart ()
	set ^pids($increment(^index))=$job
	tcommit
	for  hang 0.5
	quit

letgo
	set jdetach=1
	set jmaxwait=0
	if $&gtmposix.signalval("SIGUSR1",.sigval)
	for  quit:^index=^numjobs  hang 0.1
	set localindex=^index
	merge pidslocal=^pids
	do ^job("dsecritseize^gtm7804",1,"""""")
	do waitseize
	for i=1:1:localindex do
	.	if $zsigproc(pidslocal(i),sigval)
	; Exiting processes should try to grab crit inside mlk_unlock
	; These processes should not consume all the mutex slots if the code is ok
	do wait^job ; waits for dsecritseize only
	do checkdead ; Verify all children are dead
	quit

checkdead
	for i=1:1:localindex do
	.	for  quit:'$$^isprcalv(pidslocal(i))  hang 0.1
	quit
dsecritseize
	zsystem "source $gtm_tst/$tst/u_inref/critseize.csh"
	quit
waitseize
	set done=0
	set file="dsecritseize_gtm7804.mje1"
	; wait for file creation
	for i=1:1:300 hang 1 quit:""'=$zsearch(file)
	for timeout=1:1:300 quit:done  do
	.   hang 1
	.   open file:(exception="if $zeof=1 quit")
	.   use file
	.   for  quit:$zeof=1  do
        .   .       read line
        .   .       if line["Seized" set done=1
        .   close file
	quit
