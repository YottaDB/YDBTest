rinttp(flag) ; ; ; Test of Concurrent transactions 
	;
	;	[R]andomly [INT]erfering [TP] 
	;	  This cause often a TP to go to its last try
	;	  Needs a lot of CPU because of contention
	;
	;
	SET $ZT="g ERROR^rinttp"
	;
	; We intentionally do not use job.m for this as this is used in the filter test which currently runs
	; with GTM V4.2-002 which does not support the $zjob ISV that job.m relies on.
	;
	Set fnname="rinttp"_flag
	Set output=fnname_".mjo0",error=fnname_".mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J,!
        Close output
	;
	SET iterate=10
	s ^endloop=0
	Set ERR=0,unix=$zv'["VMS"
	;
	L +^permit
	if (flag=1) SET starti=1,endi=5 do rinttp1(0)
	if (flag=2) SET starti=2,endi=7 do rinttp2(0)
	if (flag=3) SET starti=1,endi=7 do rinttp3(0)
	;
	w "Releasing jobs...",!
	L -^permit	; All job starts at the same time
	do wait^job
	w "Starting verification...",!
	For I=starti:1:endi  if $GET(^lasti(I))'=iterate w "job",I," did not complete its iteration! TEST FAILED",!
	do in0^pfill("ver",1)
	;
	w !,$s(ERR:"FAIL",1:"PASS")," from ",$t(+0)
	q
	;

rinttp1(jmaxwait);
        w "Non-TP and TP-Rollback",!
	do ^job("thread1^rinttp",5,""""_iterate_"""")
        quit

thread1(iterate);
	if jobindex=1 do job1^rinttp(iterate)
	if jobindex=2 do job2^rinttp(iterate)
	if jobindex=3 do job3^rinttp(iterate)
	if jobindex=4 do job4^rinttp(iterate)
	if jobindex=5 do job5^rinttp(iterate)
	quit	

rinttp2(jmaxwait);
        w "Transaction Commit and TP-Rollback",!
	do ^job("thread2^rinttp",6,""""_iterate_"""")
        quit

thread2(iterate);
	if jobindex=1 do job2^rinttp(iterate)
	if jobindex=2 do job3^rinttp(iterate)
	if jobindex=3 do job4^rinttp(iterate)
	if jobindex=4 do job5^rinttp(iterate)
	if jobindex=5 do job6^rinttp(iterate)
	if jobindex=6 do job7^rinttp(iterate)
	quit	

rinttp3(jmaxwait);
        w "non-TP and Transaction Commit and TP-Rollback",!
	do ^job("thread3^rinttp",7,""""_iterate_"""")
        quit

thread3(iterate);
	if jobindex=1 do job1^rinttp(iterate)
	if jobindex=2 do job2^rinttp(iterate)
	if jobindex=3 do job3^rinttp(iterate)
	if jobindex=4 do job4^rinttp(iterate)
	if jobindex=5 do job5^rinttp(iterate)
	if jobindex=6 do job6^rinttp(iterate)
	if jobindex=7 do job7^rinttp(iterate)
	quit	


job1(iterate)	;
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(1)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . do in0^pfill("kill",(loop#10)+1)
        . do in0^pfill("set",(loop#10)+1)
	. S ^lasti(1)=loop
	q


job2(iterate);
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(2)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("set",loop+4#10+1)
        . TRollback
	. S ^lasti(2)=loop
	q

job3(iterate);
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(3)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("kill",loop#10+1)
        . TRollback
	. S ^lasti(3)=loop
	q

job4(iterate);
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(4)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("set",loop+1#10+1)
        . TRollback
	. S ^lasti(4)=loop
	q

job5(iterate);
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(5)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("kill",loop+2#10+1)
        . TRollback
	. S ^lasti(5)=loop
	q

job6(iterate)	;
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(6)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("kill",loop+4#10+1)
	. do in0^pfill("set",loop#10+1)
	. S ^lasti(6)=loop
	. TCOMMIT
	q
job7(iterate)	;
	SET $ZT="g ERROR^rinttp"
	W "PID: ",$J,!
	new loop
	L +^permit(7)
	F loop=1:1:iterate DO  q:^endloop=1
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^pfill("kill",loop+1#10+1)
	. do in0^pfill("set",loop+2#5+1)
	. S ^lasti(7)=loop
	. TCOMMIT
	q

ERROR   SET $ZT=""
        IF $TLEVEL TROLLBACK
        ZSHOW "*"
        ZM +$ZS
