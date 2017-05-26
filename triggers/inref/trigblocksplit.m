	;test1 : is the original test case that started this (Assert fail
	;GVCST_PUT.C line 435)
	;test2 : is a test where the explicit update causes an extra block split
	;test3 : is a test where the explicit update does not cause any extra
	;block splits, but the $ztval change causes an extra block split.
	;
	;In all the above cases, the trigger deletes itself (suicide) and
	;therefore prevents indefinite restarts from happening. The verification
	;routine ensures we have the correct data at the end. This verification
	;fails with V990 pro without my fix. V990 dbg fails even before at
	;different assert points.
	;
	;With the fix, things verify fine and run to completion in dbg and pro.
	;
	;The following gde settings are needed for test2 and test3.
	;
	;Once you pick these up, if you can run the same tests but with a
	;different trigger routine that does not do suicide but in turn spawns
	;off a process which does an update to a global that is already updated
	;inside the trigger thereby causing the triggering update to restart.
	;This testcase needs a way to limit the # of times it restarts. It will
	;issue TPNOTACID errors after 3 restarts and after that very soon will
	;start assert failing. You therefore need to limit this to restart a max
	;of 5 or 6 times to work around those issues. Let me know if you have any
	;questions.
trigblocksplit
	quit

init(tst);
	do ^echoline
	kill ^repetitions
	set ^a(1)=$j(2,400)
	set ^a(3)=$j(2,400)
	set ^tst=tst
	do item^dollarztrigger("tfile^trigblocksplit","trigblocksplit.trg.trigout")
	quit

test1
	do init("test1")
	set x=$increment(^a(2))
	do verify(1)
	quit

test2
	do init("test2")
	set ^a(2)=$j(2,600)
	do verify($j(2,600))
	quit

test3
	do init("test3")
	set ^a(2)=1
	do verify(1)
	quit

mrtn
	set $ztvalue=$j(2,620)
	if '$data(^conflict) zsystem "$gtm_exe/mumps -run delete^trigblocksplit"
	if $data(^conflict)  do
	.	set ^b=$j(2,400)
	.	if $select('$data(^repetitions):1,^repetitions<4:1,1:0) zsystem "$gtm_exe/mumps -run conflict^trigblocksplit"
	quit

delete
	do delete^dollarztrigger("-suicide")
	set x=$increment(^repetitions)
	quit

conflict
	set ^b=$j(2,600)
	set x=$increment(^repetitions)
	quit

verify(a2val);
	if '$data(^conflict) do
	.	if ^a(1)'=$j(2,400)  do fail
	.	if ^a(2)'=a2val  do fail
	.	if ^a(3)'=$j(2,400)  do fail
	if $data(^conflict)
	.	if ^a(1)'=$j(2,400)  do fail
	.	if ^a(2)'=$j(2,620)  do fail
	.	if ^a(3)'=$j(2,400)  do fail
	.	if ^b(2)'=$j(2,400)  do fail
	zwrite ^repetitions
	write ^tst," ---> PASS",!
	do ^echoline
	quit

fail
	write "Verify fail",!
	zshow "*"
	halt

gde
	do text^dollarztrigger("gdefile^trigblocksplit","trigblocksplit.gde")
	quit

gdefile
	;change -segment DEFAULT -file=mumps.dat
	;change -segment DEFAULT -block_size=1024
	;change -region DEFAULT -record_size=1000
	quit

tfile
	;+^a(2) -commands=S -xecute="do mrtn^trigblocksplit" -name=suicide
