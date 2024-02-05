;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm9451	;
	;
	; Create LOCKSPACEFULL situation
	for j=1:1:1000 lock +^parent($job,$$^%RANDSTR(10,,"AN")):1 quit:'$test
	;
	; Job off children to do the LOCK commands that will result in TPNOTACID messages in the syslog
	set ^stop=0	; Initialize this gvn before starting children that look at this gvn
	set jmaxwait=0	; Do not wait for children to finish. We will wait later.
	set jnolock=1	; Do not run any lock commands inside ^job as they will error out (LOCKSPACEFULL is already reached)
	set njobs=8	; need more jobs to induce TP restarts and go to final retry
	do ^job("child^gtm9451",njobs,"""""")
	;
	; Let the children run for a while. Keep waiting until one LOCK timeout happened (which implies LOCKSPACEFULL event)
	; when ^stop would get automatically set to 1. In case that never happens, time out after 60 seconds to signal failure.
	for i=1:1:60000 quit:^stop=1  hang 0.001
	;
	; Signal child pids to stop
	set ^stop=1
	do wait^job
	;
	; Note down list of parent and child pids as we will need to look for syslog messages from these pids in the caller script
	set file="pidlist.txt"
	open file:newversion
	use file
	write $job,!
	for i=1:1:njobs write ^%jobwait(i),!
	close file
	;
	quit

child	;
	do ^sstepzh	; Print each M line as it gets executed with $zh information (to help debug test failures/hangs)
	set locktimeout=0.001
	set $zmaxtptime=0	; i.e. NO timeout. This is to ensure TP timeout is more than lock timeout of 0.001 second.
	for i=1:1  quit:^stop=1  do
	. tstart ():serial
	. write "$zh = ",$zh," : i = ",i," :  $trestart = ",$trestart,!
	. ; Until we reach the final retry, do lots of sets that would create restarts
	. ; Hang between each set to greatly increase the probability of restarts amongst concurrent processes.
	. if $trestart<3 for j=1:1:100  set ^x(j)=$justify($job,$random(200)+1)  hang 0.001
	. ; Once we reach the final retry, do lots of LOCK commands that would cause a LOCKSPACEFULL situation
	. else  for j=1:1:1000 quit:^stop=1  do
	. . zwrite j
	. . lock +^a($j,$$^%RANDSTR(10,,"AN")):locktimeout
	. . ; If a lock timeout happens, it means a LOCKSPACEFULL event occurred and so we expect LOCKGCINTP message
	. . ; to have been issued (which is what the test wants to see) so signal all processes to stop at this point.
	. . set:'$test ^stop=1
	. tcommit
	. ; Release all locks obtained inside tstart/tcommit above.
	. lock
	quit

