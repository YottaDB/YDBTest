;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test    ;
	job child
	for i=1:1 quit:$zsigproc($zjob,"SIGUSR1")  hang 0.001
	do ^waitforproctodie($zjob,300)
	quit

child   ;
	set singlecpu=$ztrnlnm("gtm_test_singlecpu")
	set $zinterrupt="if $increment(intrptcnt)"
	set:(0=singlecpu) starttime=$zut
	for i=1:1:10000  set hangtime(i)=$select(i#2:0.0001,1:0.001) hang hangtime(i)
	if 0=singlecpu do
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

