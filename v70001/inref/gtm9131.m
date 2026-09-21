;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm9131	;
	view "LOGTPRESTART":1	; needed to ensure every TPRESTART message from this process is logged to syslog
	view "statshare"	; needed to open statsdb by this process
	tstart ():serial		; Start a TP transaction
	do open				; open statsdb in this process by invoking PEEKBYNAME on statsdb region
	; Start 128 child processes to force statsdb extension. Let them not terminate that way each of them will
	; use up a database block in the statsdb resulting in statsdb extension. Default statsdb allocation size is
	; 2050 blocks but caller script resets allocation to 128 so 128 processes is enough to exercise statsdb extension.
	set njobs=128
	set jobid=1
	zsystem:$trestart=0 "$gtm_dist/mumps -run job^gtm9131 "_njobs_" "_jobid
	tcommit				; Commit TP transaction where we expect a TP restart due to concurrent statsdb extension
					; since the time we accessed this statsdb at the start of this transaction. This TP
					; restart message will be recorded in the syslog and the caller script will examine it.
	do stop
	;
	; Note down list current pid in file as we will need to look for syslog messages from this pid in the caller script
	set file="pidlist.txt"
	open file:newversion
	use file
	write $job,!
	close file
	;
	quit

job	;
	set njobs=$piece($zcmdline," ",1)
	set jobid=$piece($zcmdline," ",2)	; used by "do ^job"
	set jmaxwait=0  ; do not wait for "^job" to return
	set jnolock=1   ; to avoid LOCKSPACEFULL error if njobs is in the hundreds/thousands
	set ^stop=0	; initialize global that is used by children to wait for signal from parent to stop
	do ^job("child^gtm9131",njobs,"""""")
	quit

child   ;
	view "statshare"	; needed to open statsdb by this process
	for  quit:^stop=1  hang 0.1	; wait for signal from parent to stop
	quit

stop	;
	set:'$data(jobid) jobid=$piece($zcmdline," ",1)
	set ^stop=1	; signal children to stop now that their purpose is served
	do wait^job	; wait for all children to terminate before returning
	quit

dbsize	;
	set x=$$blks()
	write "STATSDB total block count for region [default] = ",x
	quit

	; Same as "dbsize" but first waits for the statsdb to reach the expected block count, which is
	; passed as the only command line parameter. The processes whose statsdb blocks cause an
	; extension are JOBbed by "job" above, which returns without waiting for them (jmaxwait is 0,
	; since they have to stay alive for the rest of the subtest), so the count would otherwise be
	; read before they have attached. Waits up to a minute and then reports whatever it sees, so a
	; statsdb that really does not extend still fails the subtest.
dbsizewait	;
	new exp,i,x
	set exp=+$piece($zcmdline," ",1)
	for i=1:1:600 set x=$$blks() quit:x'<exp  hang 0.1
	write "STATSDB total block count for region [default] = ",x
	quit

blks()	;
	quit $$^%PEEKBYNAME("sgmnt_data.trans_hist.total_blks","default") ; lower case region name denotes the statsdb region

open	;
	set x=$$IN^%YGBLSTAT($j)       ; open statsdb in this process by invoking ^%YGBLSTATS
	quit

