;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triginstallorlbk
	do ^echoline
	write "Engage the background trigger install job",!
	do setup
	set jobid=0,jmaxwait=0
	do ^job("trigger^triginstallorlbk",1,"""""""someglobal.trg""""""")
	lock +^%rolllock ; protect ^job from online rollback
	set jobid=1,jmaxwait=0
	do ^job("roller^triginstallorlbk",1,"""""")
	lock -^%rolllock ; now let online rollback proceed
	quit

roller
	lock +^%rolllock ; wait until the parent's ^job invocation completes
	new $estack
	set $ETRAP="do ^incretrap",expect="DBROLLEDBACK"
	tstart ()
	set job=$$getjobpid("trigger_triginstallorlbk0.mjo1")
	for i=1:1:100 quit:$get(^%triggerlock,0)  hang 1
	tcommit
	do roll^trigorlbk(2)
	hang 1
	do roll^trigorlbk(1)
	quit

getjobpid(mjo)
	set saveIO=$IO
	open mjo:readonly
	use mjo
	for  quit:$zeof  read line if line["PID=" xecute "set "_line quit
	use saveIO
	quit $get(PID)


trigger(trgfile)
	set $ETRAP="do errhandler^triginstallorlbk",output=""
	write "PID=",$job,!
	set cmd=$random(2)			; 0 is $ZTRIGGER; 1 is MUPIP
	set cmd=1
	set tp=$select(cmd:0,1:$random(2))	; 0 is non-tp	; 1 is tp
	write $select(cmd:"MUPIP",1:"$ZTRIGGER"),!
	write $select(tp:"TP",1:"NONTP"),!
	set start=$HOROLOG
	set ^%triggerlock=1 ; signal to the rollback job that the trigger install is ready
	if cmd=1 do mupip^dollarztrigger(trgfile,.output)
	if cmd=0 do
	.	if tp tstart ()
	.	if ($TRESTART>1)&($ZONLNRLBK>0) trollback  use $p write "TEST-I-INFO PASS",! zwrite $TRESTART,$ZONLNRLBK halt
	.	do file^dollarztrigger(trgfile,0)
	.	if tp tcommit
	set stop=$HOROLOG
	set total=$$^difftime(stop,start)
	write "Time to load "_trgfile_" is "_$$^difftime(stop,start)_" seconds",!
	for  set resp=$order(output($get(resp))) quit:resp=""  do
	.	if output(resp)["DBROLLEDBACK" use $p write "TEST-I-INFO PASS",! halt
	write "TEST-F-FAIL",! zshow "*"
	quit

errhandler
	use $p
	if $zstatus["DBROLLEDBACK" write "TEST-I-INFO PASS",! halt
	zshow "*"
	quit

setup
	set havgbldir=$length($ztrnlnm("gtmgbldir"))
	if havgbldir quit:$data(^filecreated)
	set start=$HOROLOG
	set trgfile="someglobal.trg"
	open trgfile:newversion
	use trgfile
	for i=2:1:999999  do
	.	write "+^someglobal(",i,") -commands=ZTR -xecute=""set x=",i,"""",!
	.	write "-^someglobal(",i,") -commands=ZTR -xecute=""set x=",i,"""",!
	close trgfile
	set stop=$HOROLOG
	if havgbldir set ^filecreated=1
	set ^loadtime="Time to create "_trgfile_" is "_$$^difftime(stop,start)_" seconds"
	quit
