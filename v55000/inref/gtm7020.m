;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
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
	; this test was originally written to drive imptp which hit TRIGDEFBAD
	; and other assorted failures during normal operation. This test fires
	; off seven jobs. Each job loads two triggers. The two triggers are
	; effectively process private because they use $JOB in the trigger
	; signature. When these jobs concurrently add, remove and invoke
	; triggers they create the conditions where ^#t("GVN","#COUNT") and the
	; total number of installed triggers are in flux. Previously the C code
	; just issued a TRIGDEFBAD instead of restarting the transaction.
	;
	; The curious 15 second hang is meant to give the test enough time to
	; hit a TRIGDEFBAD. Prior versions didn't always fail with TRIGDEFBAD
	; in a reasonable amount of time.
gtm7020
	set ^stop=0
	set jmaxwait=0
	set ^incretrap("INTRA")="do intrahandler^gtm7020(%MYSTAT)"
	for i=1:1:1000  set (^a(i),^a(i,i+i))=i
	set file="gtm7020.outx"
	open file:newversion
	use file
	do ^job("job^gtm7020",7,"""""")
	close file
	do ^echoline
	hang 15
	do stop
	do ^echoline
	quit

job
	set $ETRAP="goto ^incretrap"
	do action^gtm7020(1,1) do action^gtm7020(2,1)
	for  quit:^stop=1  do
	.	new $estack,data
	.	merge data=^a
	.	set which=$random(2)+1
	.	do procpriv(which)
	.	ztrigger:$data(^aprivate(which,$job)) ^aprivate(which,$job)
	quit

stop
	tstart ()
	set ^stop=1
	tcommit
	hang .5	; fast machines need this so that the test does not complete before the child processes
	write "The test system should not find any cores or mention of TRIGDEFBAD",!
	quit

intrahandler(zstatus)
	quit:zstatus'["TRIGDEFBAD"
	write "YDB-E-TRIGDEFBAD encountered with $TLEVEL=",$TLEVEL," $TRESTART=",$TRESTART,!
	quit

	; load a process specific trigger by embedding $job in the trigger specification and name
	; Output
	;   This routine will output the trigger and the results of $ztrigger. It's worthwhile to
	;   note that when $ztrigger is not wrapped by a transaction and a restart occurs, $ztrigger
	;   outputs an extra message:
	;   "RESTART has invalidated this transaction's previous output.  New output follows."
	;   When wrapped by a tstart the $ztrigger is repeated without any other notice.
procpriv(line)
	if $data(line)=0 set line=1
	new option,trigspec,op,wraptp
	set option=$random(2)+1
	; add/delete only when these is not/is a trigger loaded
	; quit if option = 1 (add) and the trigger is already loaded
	quit:(option=1&$data(^aprivate(line,$job)))
	; quit if option = 2 (delete) and the trigger is not loaded
	quit:(option=2&'$data(^aprivate(line,$job)))
	do action(line,option)
	quit

action(line,option)
	set wraptp=$random(2)
	set op=$select(option=1:"+",1:"-")
	set trigspec=$text(triggers+line^gtm7020)
	set trigspec=op_$piece(trigspec,";",2)_$job_$piece(trigspec,";",4)_$job
	if $data(^debug) write $data(^aprivate(line,$job)),?2,trigspec,$char(9),"-->",$char(9)
	if wraptp tstart ()
	set ztrigret=$$direct^dollarztrigger("item",trigspec)
	if ztrigret=0 write "%YDB-E-FAIL ^aprivate(",line,",$job)",! zshow "*"
	else  set:option=1 ^aprivate(line,$job)=$job zkill:option=2 ^aprivate(line,$job)
	if wraptp tcommit
	quit

triggers
	;^aprivate(1,;$job;) -commands=ZTR -xecute="set x=$increment(^aprivate(1,$job))" -name=procpriv1S;$job
	;^aprivate(2,;$job;) -commands=ZTR -xecute="set x=$increment(^aprivate(2,$job))" -name=procpriv2S;$job
	quit
