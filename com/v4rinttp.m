v4rinttp(flag) ; ; ; Test of Concurrent transactions 
	;
	;	[R]andomly [INT]erfering [TP] 
	;	  This cause often a TP to go to its last try
	;	  Needs a lot of CPU because of contention
	;
	;
	SET $ZT="g ERROR^v4rinttp"
	;
	; We intentionally do not use job.m for this as this is used in the filter test which currently runs
	; with GTM V4.2-002 which does not support the $zjob ISV that job.m relies on.
	;
	Set fnname="v4rinttp"_flag
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
	if (flag=1) SET starti=1,endi=5,ITEM="Non-TP and TP-Rollback" 
	if (flag=2) SET starti=2,endi=7,ITEM="Transaction Commit and TP-Rollback"
	if (flag=3) SET starti=1,endi=7,ITEM="non-TP and Transaction Commit and TP-Rollback"
	w ITEM,!
	For I=starti:1:endi do
        . If unix J @("job"_I_"^v4rinttp(iterate):(output="""_fnname_".mjo"_I_""":error="""_fnname_".mje"_I_""")")
        . Else  J @("job"_I_"^v4rinttp(iterate):(STARTUP=""STARTUP.COM"":output="""_fnname_".mjo"_I_""":error="""_fnname_".mje"_I_""")")
        . H 3
	w "Releasing jobs...",!
	L -^permit	; All job starts at the same time
	h 0		; Wake the jobs waiting for lock
	h 30
	L +^permit  L	; Get the lock before verify, to ensure that all child job has finished
	w "Starting verification...",!
	For I=starti:1:endi  if $GET(^lasti(I))'=iterate w "job",I," did not complete its iteration! TEST FAILED",!
	do in0^pfill("ver",1)
	;
	h 10
	w !,$s(ERR:"FAIL",1:"PASS")," from ",$t(+0)
	q
	;
	;
	;



job1(iterate)	;
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
	SET $ZT="g ERROR^v4rinttp"
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
