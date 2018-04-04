;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
trigrlbk ;
	; load the trigger file before doing the test
	do text^dollarztrigger("tfile^trigrlbk","trigrlbk.trg")
	do file^dollarztrigger("trigrlbk.trg",1)

	; single threaded test (test output)
	do init
	set ^disp=1
	set ^njobs=1
	set ^maxdepth=5
	set ^maxindex=10
	write "#######################################",!
	write "Single thread with maxdepth=",^maxdepth,!
	write "#######################################",!
	do child

	; single threaded test (with maximum depth)
	do init
	set ^disp=0
	set ^njobs=1
	set ^maxdepth=127
	set ^maxindex=100000
	write "#######################################",!
	write "Single thread with maxdepth=",^maxdepth,!
	write "#######################################",!
	do child

	; multi threaded test (to test TP restarts inside nested triggers; output is not nested; only tested for no assert failures)
	do init
	set ^disp=0
	set ^njobs=1+$random(10)
	set ^maxindex=100000
	set ^maxdepth=1+$random(126)
	set jmaxwait=0
	write "#######################################",!
	write "Multi thread test with maxdepth=",^maxdepth,!
	write "#######################################",!
	do ^job("child^trigrlbk",^njobs,"""""")
	hang 30
	set ^stop=1
	do wait^job
	quit

init	;
	kill ^cnt,^CIF,^disp,^maxindex,^maxdepth,^njobs
	set ^stop=0
	quit

child	;
	set $etrap="do etr^trigrlbk"
	do helper
	zwr ^cnt,^CIF
	quit

helper	;
	if ^njobs=1  set pid="pid"
	else  set pid="pid"_jobindex
	for i=1:^maxdepth:^maxindex  quit:^stop=1  do
	.	set x=$INCR(^CIF(i,pid))
	quit

etr	;
	if ^disp  write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $tlevel=",$tlevel," : $ecode=",$ecode," : ZSTATUS=",$zstatus,!
	; make sure that the error is a anticipated failure for this test
	set curZS=$piece($zstatus,",",3)
	if $select(curZS="%YDB-E-TRIGTLVLCHNG":1,curZS="%YDB-E-SETINTRIGONLY":1,1:0)  set $ecode=""
	else  do
	.	write "Unanticipated failure occured, halting",!
	.	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $tlevel=",$tlevel," : $ecode=",$ecode," : ZSTATUS=",$zstatus,!
	.	zshow "*"
	.	halt
	if ($data(acn))  do
	.	set cnt=$incr(^cnt)
	.	tstart ():serial
	.	set ^CIF(-acn,pid)=cnt
	.	tcommit
	quit

TRIG
	set maxdepth=$select(^maxdepth=1:1,1:^maxdepth-1)
	set acnmod=acn#($select(^maxdepth=1:127,1:^maxdepth))
	; only when acnmod=(^maxdepth-1), cause the SETINTRIGONLY error
	; if acn is positive, the sets are issued by the M routine and this trigger routine
	if ((0<acn)&(0<acnmod)) do
	.	if maxdepth=acnmod set $ztval="ztval("_acn_")"  ; should NOT issue SETINTRIGONLY error
	.	trollback
	.	if $tlevel'=0  zshow "*"  halt                  ; halt if trollback failed
	.	set ^CIF(acn+1,pid)=$incr(^cnt)_"SUF..."_$j(" ",1500)_"...FIX"                 ; nest triggers - SETINTRIGONLY occurs during trigger unwind
	.	if maxdepth=acnmod set $ztval="ztval("_acn_")"  ; should issue SETINTRIGONLY error even though $ztlevel>0
	; if acn is negative, the sets are from the error trap
	if (0>acn)  set $ztval=$ztval+0.5  ; test valid $ztval update AFTER trollback
	quit

tfile
	;+^CIF(acn=:,pid=:) -commands=set -xecute="do TRIG^trigrlbk"
