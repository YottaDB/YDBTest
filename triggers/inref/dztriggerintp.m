;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; The purpose of this test is make sure that use of the function
	; $ztrigger is valid inside an explicit transaction
	;
	; - explicit tstart/tcommit and no trigger context
	; - trollback (trollback with parameter)
	; - trollback generic (trollback w/o parameter)
	; - test halts for implicit rollbacks
	; - trestart
dztriggerintp
	do ^echoline
	do genrollbck
	do rollbck
	do rollbckt1
	do rollbckt2
	do rollbckt3
	do restnroll
	do simplicit
	do explicit
	do improllbck
	do restart
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - explicit tstart/tcommit with no trigger context
	;	use $ztrigger inside a transaction and change existing triggers
explicit
	do ^echoline
	set $ztwormhole=""
	write "$gtm_exe/mumps -run explicit^dztriggerintp",!
	do text^dollarztrigger("explicittfileorig^dztriggerintp","explicitorig.trg")
	do text^dollarztrigger("explicittfile^dztriggerintp","explicit.trg")
	do file^dollarztrigger("explicitorig.trg",1)
	kill ^a,^b,^c,^fired,i,p
	tstart ()
	set $piece(^a,"|",$increment(i))=i
	set $piece(^b,"|",$increment(i))=i
	set $piece(^c,"|",$increment(i))=i
	do file^dollarztrigger("explicit.trg",1)
	set $piece(^a,"|",$increment(i))=i
	set $piece(^c,"|",$increment(i))=i
	set $piece(^b,"|",$increment(i))=i
	tcommit
	set p=""
	for  set p=$order(^fired(p)) quit:p=""  if ^fired(p)>1  set i=-1
	if i>0  write "PASS",!
	else  write "FAIL",!
	do ^echoline
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - explicit tstart/tcommit with no trigger context
	;	simple case - use $ztrigger inside a transaction
	;	dump triggers before, inside and after transaction
	;	we don't expect to see them in the DB until tcommit
simplicit
	do ^echoline
	set $ztwormhole=""
	new begin,done,outside,inside
	set begin="begin_simplicit.trg",done="done_simplicit.trg"
	set outside="outside_simplicit.trg",inside="inside_simplicit.trg"
	; delete the file used by mupip if it already exists, simplifies debugging
	open outside close outside:delete
	write "$gtm_exe/mumps -run simplicit^dztriggerintp",!
	do delete^dollarztrigger()
	do select^dollarztrigger(,begin)
	tstart ()
	do text^dollarztrigger("explicittfile^dztriggerintp","simplicit.trg")
	do file^dollarztrigger("simplicit.trg",1)
	do select^mupiptrigger(,,outside)
	hang 5
	do select^dollarztrigger(,inside)
	tcommit
	do select^dollarztrigger(,done)
	; compare the select trigger files
	open done:readonly open inside:readonly
	open begin:readonly open outside:readonly
	; begin vs outside should be the same
	for i=1:1 quit:$zeof  do
	.	use begin  read:'$zeof lineA
	.	use outside read:'$zeof lineB
	.	if lineA'=lineB set fail(i,begin)=lineA,fail(i,outside)=lineB
	; done vs inside should be the same
	for i=1:1 quit:$zeof  do
	.	use done  read:'$zeof lineA
	.	use inside read:'$zeof lineB
	.	if lineA'=lineB set fail(i,done)=lineA,fail(i,inside)=lineB
	close begin close done close inside close outside
	use $p
	if $data(fail) write "FAIL",! zwrite fail
	else  write "PASS",!
	do ^echoline
	quit
explicittfile
	;-*
	;+^a -commands=S -xecute="do l^mrtn()" -name=explicita
	;+^b -commands=S -xecute="do l^mrtn()" -name=explicitb
	;+^z -commands=S -xecute="set x=1 do l^mrtn()" -name=explicitz2
	quit
explicittfileorig
	;-*
	;+^z -commands=S -xecute="do l^mrtn()" -name=explicitz
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - trestart
	;	tstart
	;	if $trestart<2 tstart update A trestart
	;	change trigger A
	;	tcommit
restart
	do ^echoline
	set $ztwormhole=""
	write "$gtm_exe/mumps -run restart^dztriggerintp",!
	do text^dollarztrigger("restarttfile^dztriggerintp","restart.trg")
	do text^dollarztrigger("restarttfile2^dztriggerintp","restart2.trg")
	do file^dollarztrigger("restart.trg",1)
	kill ^a,^fired,i
	do all^dollarztrigger
	tstart ()
	if $trestart<2 tstart () set $piece(^a,"|",$increment(i))=i trestart
	do file^dollarztrigger("restart2.trg",1)
	set $piece(^a,"|",$increment(i))=i
	tcommit
	if ^a=$ztwormhole,^fired("+1^restarty#")=1 write "PASS",!
	else  write "FAIL",! zwrite
	do ^echoline
	quit
restarttfile
	;-*
	;+^a -command=S -xecute="set x=1 do l^mrtn()" -name=restartx
	quit
restarttfile2
	;-restartx
	;+^a -command=S -xecute="set y=1 do l^mrtn()" -name=restarty
	quit


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - test halts for implicit rollbacks
improllbck
	do ^echoline
	set $ztwormhole=""
	write "$gtm_exe/mumps -run improllbck^dztriggerintp",!
	do item^dollarztrigger("improllbcktfile^dztriggerintp","improllbck.trigout")
	kill ^A,^fired
	set jnoerrchk=1
	do ^job("improllbckmain^dztriggerintp",1,"""""")
	if '$data(^A),'$data(^fired) write "PASS",!
	do ^echoline
	quit
improllbckmain
	tstart ()
	set ^A="This will not be here after halt"
	do delete^dollarztrigger()
	halt
	tcommit
	quit
improllbcktfile
	;-*
	;+^a -command=S -xecute="do l^mrtn()" -name=improllback
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - trollback
	;	load trigger A + AB
	;	tstart x 3
	;	update A (firing trigger)
	;	delete trigger AB and load a replacement
	;	update A (firing trigger)
	;	trollback -2
	;	update AB (firing original AB trigger)
	;	tcommit
rollbck
	do ^echoline
	set $ztwormhole=""
	write "$gtm_exe/mumps -run rollbck^dztriggerintp",!
	; delete triggers because the first trigger load occurs inside a transaction
	do item^dollarztrigger("rollbcktfile^dztriggerintp","rollbck.trigout")
	kill ^a,^fired,i
	; indenting to show TLEVEL
	tstart ()
		tstart ()
			tstart ()
			set $piece(^a,".",$increment(i))="Do you want to play a game?"
				write "here",!
			do item^dollarztrigger("rollbcktfile2^dztriggerintp","rollbck.trigout")
				write "there",!
			set $piece(^a,".",$increment(i))="Disappearing.Act"
				write "where",!
			if '$data(^fired("+1^rollback1#"))  write "FAIL",!,"rollback1 did not fire",!
			trollback -2 ; triggers for ^a have fired
	set $piece(^ab,".",$increment(i))="Magic Trick"
	tcommit
	;
	if $select('$data(^fired):1,$data(^a):1,$data(^fired("+1^rollback22#")):1,1:0) do
	.	write "FAIL",!
	.	zwrite:$data(^a) ^a			; should have been rolled back
	.	zwrite:$data(^fired) ^fired	; should exist with trigger rollback11 firing
	.	zwrite:$data(^ab) ^ab
	else  do
	.	if ^fired("+1^rollback11#")=1,^ab="..Magic Trick" write "PASS",!
	.	else  write "FAIL",!,$ztwormhole,! zwr ^a,^fired
	do ^echoline
	quit
rollbcktfile
	;-*
	;+^a -command=S -xecute="do l^mrtn()" -name=rollback1
	;+^ab -command=S -xecute="set x=1 do l^mrtn()" -name=rollback11
	quit
rollbcktfile2
	;-rollback11
	;+^ab -command=S -xecute="set x=2 do l^mrtn()" -name=rollback22
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Additional trollback and trestart tests
	;
	;
rollbckt1
	; Test that any $ZTRIGGER followed by the explicit update (triggering the implicit update) are all
	; rolled back without any remenants. An update to the same global after the rollback should NOT
	; invoke triggers.
	; Also ensure that db_trigger_cycle is NOT incremented.
	do ^echoline
	write "$gtm_exe/mumps -run rollbckt1^dztriggerintp",!
	do delete^dollarztrigger()	;delete all triggers
	; Print the DB Trigger Cycle
	zsystem "$gtm_exe/dse dump -file -all |& grep ""DB Trigger cycle"""
	kill ^a,^fired,i
	tstart ()
	set x=$increment(^a)
	do text^dollarztrigger("rollbcktrg1^dztriggerintp","rollbcktrg1.trg")
	do file^dollarztrigger("rollbcktrg1.trg",1)
	set x=$increment(^a)
	trollback
	set x=$increment(^a)
	; verify
	; Print the DB Trigger Cycle
	zsystem "$gtm_exe/dse dump -file -all |& grep ""DB Trigger cycle"""
	if '$data(^fired),$data(^a)=1 write "PASS",!
	else  write "FAIL",!
	do ^echoline
	quit

rollbckt2
	;Test: inner transaction loads new triggers and deletes all triggers loaded by the parent transaction
	; and is rolled back. Subsequent updates use original triggers.
	do ^echoline
	write "$gtm_exe/mumps -run rollbckt2^dztriggerintp",!
	do delete^dollarztrigger()
	kill ^a,^fired,i
	do text^dollarztrigger("rollbcktrg1^dztriggerintp","rollbcktrg1.trg")
	do text^dollarztrigger("rollbcktrg2^dztriggerintp","rollbcktrg2.trg")
	tstart ()
	do file^dollarztrigger("rollbcktrg1.trg",1)
	set x=$increment(^a)	; ^a=1, does drive trigger (which we call old trigger)
		tstart ()
		do file^dollarztrigger("rollbcktrg2.trg",1)	; Load new trigger for ^a
		set ^a=100	; ^a=100, ^fired(100)=101
		trollback -1	; rollback this transaction which negates all the updates done inside this transaction
	set x=$increment(^a)	; ^a=3 and invoke l^mrtn() (continues to drive old trigger since new trigger is invisible)
	tcommit
	set x=$increment(^a)
	; verify
	if ^a=3,$data(^fired("+1^rollbck1#")) write "PASS",!
	else  write "FAIL",!
	do ^echoline
	quit

rollbckt3
	;Simple test case to ensure that in a transaction without rollbacks (i.e., properly committed), only the latest
	; $ZTRIGGER() is used by subsequent updates. Almost a copy of the earlier test with the exception of a tcommit
	; instead of a trollback -1 and kill ^fired inside nested tstart()
	set $ztwormhole=""
	do ^echoline
	write "$gtm_exe/mumps -run rollbckt3^dztriggerintp",!
	do delete^dollarztrigger()
	kill ^a,^fired,i
	do text^dollarztrigger("rollbcktrg1^dztriggerintp","rollbcktrg1.trg")
	do text^dollarztrigger("rollbcktrg2^dztriggerintp","rollbcktrg2.trg")
	tstart ()
	set x=$increment(^a)    ; ^a=1, does not drive a trigger, therefor does not cause TIGMODINTP
	do file^dollarztrigger("rollbcktrg1.trg",1)
		tstart ()
		kill ^fired	; Kill previously triggered updates
		do file^dollarztrigger("rollbcktrg2.trg",1)     ; Load new trigger for ^a
		set ^a=100      ; ^a=100, ^fired(100)=101
		tcommit
	set x=$increment(^a)	; ^a=101, ^fired(101)=102
	tcommit
	set x=$increment(^a)	; ^a=102, ^fired(102)=103
	; verify
	if ^a=102,^fired(100)=101,^fired(101)=102,^fired(102)=103,'$data(^fired("+1^rollbck1#")) write "PASS",!
	else  write "FAIL",!
	do ^echoline
	quit

restnroll
	; Mix of restarts and rollbacks
	do ^echoline
	write "$gtm_exe/mumps -run restnroll^dztriggerintp",!
	do delete^dollarztrigger()
	kill ^a,^fired,i
	do text^dollarztrigger("rollbcktrg1^dztriggerintp","rollbcktrg1.trg")
	do text^dollarztrigger("rollbcktrg2^dztriggerintp","rollbcktrg2.trg")
	do text^dollarztrigger("rollbcktrg3^dztriggerintp","rollbcktrg3.trg")
	tstart ()
	if $trestart=0 do
	.	do file^dollarztrigger("rollbcktrg1.trg",1)
	.	set x=$increment(^a)
	else  if $data(^a),$ztrigger("s") write "FAIL",!	; above trigger & ^a update are discarded by a subsequent trestart
	; the above indenting is not the same for below
		tstart ()
		if $trestart=0  trestart
		; With $trestart=1 at this point, ^a, ^fired Should NOT exist
		set x=$increment(^a)	; ^a=1 (at both $trestart = 1 and $trestart = 2)
			tstart ()
			do file^dollarztrigger("rollbcktrg3.trg",1) ; no TRIGMODINT because this affects ^b and not ^a
			if $trestart=1  trestart
			set x=$increment(^a)
			trollback -1	; essentially discards all the updates to ^a and ^fired in this transaction
		do file^dollarztrigger("rollbcktrg2.trg",1)	; Load new trigger for ^a
		set ^b=$trestart
		tcommit
	set x=$increment(^a)	; ^a=2, ^fired(2)=3
	tcommit
	set x=$increment(^a)	; ^a=3, ^fired(3)=4
	; verify
	if ^b=2,^a=3,^fired(2)=3,^fired(3)=4,'$data(^fired("+1^rollbckb#")),'$data(^fired("+1^rollbck1#")) write "PASS",!
	else  write "FAIL",!
	do ^echoline
	quit

rollbcktrg1
	;-*
	;+^a -commands=S -xecute="do l^mrtn()" -name=rollbck1
	quit

rollbcktrg2
	;-*
	;+^a -commands=S -xecute="set ^fired($ztvalue)=$ztvalue+1" -name=rollbck2
	quit

rollbcktrg3
	;+^b -commands=S -xecute="do l^mrtn()" -name=rollbckb
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - trollback - generic
	;	load validtriggers.trg
	;	tstart x2
	;	delete all triggers
	;	tcommit
	;	do some updates
	;	trollback
genrollbck
	do ^echoline
	set $ztwormhole=""
	do delete^dollarztrigger()
	write "$gtm_exe/mumps -run genrollbck^dztriggerintp",!
	kill ^a,^fired,i
	do copyvalidtrg("valid.trg")
	do file^dollarztrigger("valid.trg",1)
	tstart ()
	tstart ()
	do delete^dollarztrigger()
	set $piece(^a,"|",$increment(i))="Does not fire a trigger"
	tcommit
	set $piece(^a,"|",$increment(i))="Does not fire a trigger x 2"
	trollback
	; transaction is now over!, ^a has not been set!
	if $select($data(^a):1,$data(^fired):1,1:0)  write "FAIL",!
	set $piece(^a,"|",$increment(i))="Fires a trigger"
	write "Expect to see only the last trigger in $ztwormhole",!
	if $ztwormhole="||Fires a trigger" write "PASS",!
	else   write "FAIL",!,"$ztwormhole=",$ztwormhole,!
	do ^echoline
	quit
copyvalidtrg(destination)
	new source,line
	set source="$gtm_tst/$tst/inref/validtriggers.trg"
	open source:readonly
	open destination:newversion
	use source
	for  quit:$zeof  do
	.	read line
	.	use destination
	.	set start=$find(line,"^twork",1)
	.	set:start>0 $extract(line,start-6,start-1)="l^mrtn()"
	.	write line,!
	.	use source
	close source
	quit


