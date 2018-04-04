;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trigorlbk
	new $estack
	set incretrap("INTRA")="do etraphandler(%MYSTAT)"
	set $etrap="do ^incretrap"
	set jmaxwait=0	; don't wait for child jobsa
	; fire off imptp jobs
	set jobid=0
	do ^imptp(3)
	; wait for some time / transactions so that we have a valid seqno to roll back to
	set waittime=10	; wait for 10 seconds OR
	set seqno=10	; wait for 10 transactions
	set curseqno=+$$getcurseqno^getresyncseqno("jnl")
	for wait=1:1:waittime quit:curseqno>seqno  set curseqno=+$$getcurseqno^getresyncseqno("jnl") hang 1
	; use the last curseqno as the target rollback seqno
	do item^dollarztrigger("tfile^trigorlbk","trigorlbk.trg.trigout")
	; avoid the edge case of job.m being hit by online rollback by using locks
	lock +^%rolllock
	set jobid=1
	do ^job("roll^trigorlbk",1,""""_curseqno_"""")
	lock -^%rolllock
	; start the main test
loop	tstart *:(serial)       ; * is important since we want to preserve 'i' across restarts
	if $zonlnrlbk  write "TEST-I-INFO online rollback happened -- $trestart=",$trestart,!
	if $trestart>2 trollback  goto loop ; don't hold crit, $trestart 3 or more, trollback
	for i=1:1  quit:$zonlnrlbk  do
	.	set ^a2orlbk(i)=$justify(i,10)
	.	hang 0.25	; avoid sitting in a tight loop
	.	set ^%2orlbk=i
	.	quit:($get(^stop,0)=1)!($zonlnrlbk)
	tcommit
	if $data(^b2orlbk) write "TEST-F-FAIL : ^b2orlbk is defined",! zwrite ^b2orlbk
	zwrite i
	if $data(^%2orlbk) zwrite ^%2orlbk
	if $data(^a2orlbk) zwrite ^a2orlbk
	quit

roll(seqno)
	new i,pass,pipe,line
	lock +^%rolllock
	set $ETRAP="use $p zshow ""*"" halt"
	set pass=0
	set pipe="pipe"
	open pipe:(shell="/bin/sh":command="$MUPIP journal -rollback -backward -verbose -online -resync="_seqno_" ""*"" 2>&1 | tee -a orlbk.outx")::"pipe"
	use pipe
	for i=1:1 quit:$zeof  read line(i)
	close pipe
	use $p
	for  quit:i<2  if line($i(i,-1))["ORLBKCMPLT" set pass=1 quit
	if (pass=0)&($data(line)) write "TEST-F-FAIL",! zwrite line,i
	lock -^%rolllock
	quit

stop
	set $ETRAP="do ^incretrap"
	set incretrap("INTRA")="do etraphandler^trigorlbk(%MYSTAT)"
	set ^%stop=1  ; trip DBROLLEDBACK
	do ^endtp
	quit

waitreadseqnoupdate	;
	; See parent script (u_inref/trigorlbk.csh) for more comments on why this routine is invoked.
	; wait for source server to update gtmsource_local->read_jnl_seqno after reconnection with receiver server
	; after an online rollback
	;
	for  do  quit:lastjnlseqno>=lastsentseqno  hang 0.1
	. ; $extract needed below to remove 0x before passing it on to HD to convert hex number to a decimal number
	. set lastjnlseqno=$$FUNC^%HD($extract($$^%PEEKBYNAME("jnlpool_ctl_struct.jnl_seqno"),3,99))
	. set lastsentseqno=$$FUNC^%HD($extract($$^%PEEKBYNAME("gtmsource_local_struct.read_jnl_seqno",0),3,99))
	. write "$zh=",$zh," : lastjnlseqno = ",lastjnlseqno," : lastsentseqno = ",lastsentseqno,!
	quit

etraphandler(err)
	set disperr=0
	quit:err["DBROLLEDBACK"
	; not online rollback, we want to see this error
	set disperr=1
	zshow "s"
	quit

tfile
	;+^a2orlbk(sub=:) -commands=SET -xecute="set ^b2orlbk(sub,$job)=$ztvalue"
