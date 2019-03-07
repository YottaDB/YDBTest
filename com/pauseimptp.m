;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
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
pauseimptp
pauseifneeded ; called from slowfill.m and imptp.m
	if ($get(^%pauseflag,0)) do
	.  if $increment(^%pauseflag(fillid,"pausedcount"))
	.  for  quit:0=^%pauseflag  hang 0.5
	.  if $increment(^%pauseflag(fillid,"pausedcount"),-1)
	quit

pause
	new fillid,jobcount,maxwait,start,elapsed
	set maxwait=300 ; in seconds
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	set ^%pauseflag=1
	set jobcount=+$ztrnlnm("gtm_test_jobcnt")
	set:jobcount=0 jobcount=5 ; Default job count is 5 (see jobcnt.m)
	set elapsed=0
	set start=$horolog
	; Make sure all of the processes have paused
	for  quit:(elapsed>maxwait)!($get(^%pauseflag(fillid,"pausedcount"),0)=jobcount)  do
	.    hang 0.5
	.    set elapsed=$$^difftime($horolog,start)
	; Flush the database and journal buffers
	view "FLUSH"
	do timeoutcheck
	; Note that even though we flushed the database and journal files above, we would write a PFIN record
	; as part of halting and it could so happen that PFIN record crosses over a filesystem blocksize boundary
	; in its position in the journal file. In that case, one of the imptp jobs (that is currently paused)
	; could flush this PFIN record to the journal file (as part of its flush timer activity) causing a journal
	; file size change when the caller would not be expecting it (since it thinks everything is paused).
	; Therefore the caller (v54001/u_inref/C9J04003116.csh is the only one currently) should still do a journal file flush.
	quit

resume
	new fillid,maxwait,start,elapsed
	set maxwait=300
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	set ^%pauseflag=0
	set elapsed=0
	set start=$horolog
	; Make sure all of the processes are continuing
	for  quit:(elapsed>maxwait)!(0=$get(^%pauseflag(fillid,"pausedcount"),0))  do
	.    hang 0.5
	.    set elapsed=$$^difftime($horolog,start)
	do timeoutcheck
	kill ^%pauseflag
	quit

timeoutcheck
	if (elapsed>maxwait) do
	.  write "TEST-E-IMPTP IMPTP could not be paused or resumed."
	.  zwrite ^%pauseflag
	.  halt
	quit
