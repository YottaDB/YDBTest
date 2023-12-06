;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
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
	; Let the children run for a while
	hang 15
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
	do ^sstep	; Print each M line as it gets executed (to help debug test failures/hangs)
	set locktimeout=1
	set $zmaxtptime=0	; i.e. NO timeout. This is to ensure TP timeout is more than lock timeout of 1 second.
	for i=1:1  quit:^stop=1  do
	. tstart ():serial
	. ; Until we reach the final retry, do lots of sets that would create restarts
	. if $trestart<3 for j=1:1:100  set ^x(j)=$justify($job,$random(200)+1)
	. ; Once we reach the final retry, do lots of LOCK commands that would cause a LOCKSPACEFULL situation
	. else  for j=1:1:1000 quit:^stop=1  zwrite j lock +^a($j,$$^%RANDSTR(10,,"AN")):locktimeout
	. tcommit
	. ; Release all locks obtained inside tstart/tcommit above.
	. lock
	quit

