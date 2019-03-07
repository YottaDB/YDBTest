;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2009-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lockspacefull(test,show)
	; get a lock for ^a
	; If show=1 then this test will output LKE SHOW -WAIT once all processes are launched.
	; The output of LKE SHOW -WAIT can be used to calculate maximum lock queue capacity.
	; CAUTION: The stop condition of this code is dependent on LKE SHOW -WAIT output.
	; If show=0 make sure you fully occupy or overload lock space otherwise the test will hang.
	; If show=1 do not occupy all lock space otherwise the test will hang.
	; The reson for this is the number of lines differ in LKE SHOW output due to
	; additional error messages at the end (LOCKSPACEFULL/LOCKSPACEINFO)
	; The last will cause the YDB-E-LOCKSPACEFULL error.
	set unix=$zversion'["VMS"
	set addlocks=test
	set ^a=0
	set jdetach=1
	set jnoerrchk=1
	set jmjoname="justlock"
	set jmaxwait=0
	set jnolock=1
	set plaunched=0
	set:show file="jwait_queue.show_list"
	set:'show file="jwait_queue.simlist_list"
	; Added 4 below because there is one empty line, one region header line, one LOCKSPACEINFO line and one LOCKSPACEUSE message at the end
	set zsywaitchld="$LKE show -wait >& "_file,expline=addlocks+4
	; If we are running with show=0, we are trying to overload the memory. In that case, the last lock will not show up in the
	; lke show -wait output. Substract one line due to the overloaded lock that doesn't show up in the lke output, add 2 lines
	; due to LOCKSPACEFULL and LOCKSPACEINFO messages (+2-1=+1 below)
	if 'show set expline=expline+1
	set ^debu=expline
	lock ^a
	do ^job("justlock^lockspacefull",addlocks,"""""")
	if (unix)&'show do
	.  zsystem "$gtm_tst/com/getoper.csh ""$syslog_before1"" """" syslog1.txt """" ""YDB-E-LOCKSPACEFULL"""
	else  do
	.  for  quit:plaunched  do
	.  . zsystem zsywaitchld
	.  . do countlinesize^lockspacefull
	.  . set:expline=^linecnt plaunched=1
	; show means that we are simply trying to understand lock space capacity
	zsystem:show "$LKE show"
	; Save the latest block usage for debugging purposes
	zsystem:'show&unix "$LKE show -mem >& lock_blocks.txt"
	lock
	; wait for the jobs to complete
	do wait^job
	quit

justlock
	write "PID: ",$job,!
	write "locking ^a at : ",$zdate($H,"12:60:SS"),!
	lock ^a
	set ^a=^a+1
	write ^a,!
	write "Exiting at : ",$zdate($H,"12:60:SS"),!
	halt

countlinesize
	set ^linecnt=0
	open file:(exception="if $zeof=1 quit")
	use file
	for  quit:$zeof=1  do
	.       read line
	.	set ^linecnt=$increment(^linecnt)
	close file
	use $p
	quit
