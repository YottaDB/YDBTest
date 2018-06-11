;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012, 2014 Fidelity Information Services, Inc	;
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
gtm7254(thr)
	set ^threshold=thr ; Minimum # of updates that should be done by other processes when we reach 100
	set ^numproc=8
	set ^seq=0
	set jmaxwait=0
	set jdetach=1
	set jmjoname="nolockprocout"
	do ^job("lockit^gtm7254",^numproc,0)
	do wait^job
	set jmjoname="lockprocout"
	do ^job("lockit^gtm7254",^numproc,1)
	do wait^job
	quit
lockit(timed)
	if timed write "Trying with timed lock",! set lcomm="+^x:60"
	else  write "Trying with untimed lock",! set lcomm="+^x"
	for i=1:1:100 do
	.	lock @(lcomm)
	.	if (timed&(0=$test)) write "TEST-E-FAIL This process waited more than 60 seconds for a timed lock",!
	.	write "o"
	.	set ^update($increment(^seq))=index ; Keep update order in a global
	.	; fake some activity inside the lock critical section. not doing so can cause one process to finish
	.	; its lock/unlock sequence so fast that other processes might not have queued up for that lock by then
	.	; and so the first process could do multiple lock/unlock sequences before the first queueup happens
	.	; and this fairness test will incorrectly fail. in real code inside lock critical section is not a no-op
	.	; so this sleep fake of activity should be acceptable for test purposes.
	.	hang 0.01
	.	if $increment(^count(index))
	.	if 100=i do	 ; check for fairness that peer threads have done at least threshold% of their work when we are done 100%
	.	.	for j=1:1:^numproc if (index'=j)&(^threshold>^count(j)) do
	.	.	.	write !,"TEST-E-FAIL This process held the lock unfairly. ^count(",j,") = ",^count(j),!
	.	lock -^x
	.	; Wait until all other processes finish their very first update. This is done to ensure all children started.
	.	; Currently, job.m mechanism is insufficient to ensure all of the children started at the same time. This
	.	; loop may be removed after job.m is improved to start all jobs simultaneously.
	.	if i=1  do
	.	.	for j=1:1:^numproc  if (index'=j) do
	.	.	.	for  quit:$data(^count(j))  hang 0.01
	quit

