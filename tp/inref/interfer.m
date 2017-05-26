interfer(flag); ; ; Test of Concurrent transactions 
        ;
        ;        Inerfering TP 
        ;        This cause often a TP to go to its last try
        ;        Needs a lot of CPU because of contention
        ;
        SET $ZT="g ERROR^interfer"
        ;
        Set fnname="interfr"_flag
        Set output=fnname_".mjo0",error=fnname_".mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J,!
        Close output
        ;
        SET iterate=1
        s ^endloop=0
        Set ERR=0,unix=$zv'["VMS"
        ;
        L +^permit
	set jmaxwait=0
        do @fnname^interfer
        w "Releasing jobs...",!
        L -^permit      ; All job starts at the same time
	do wait^job
        if (flag=1) DO
        .  w "Starting verification...",!
        .  do in0^dbfill("ver")
        .  do in1^dbfill("ver")
        if (flag=2) DO
        .  w "Starting verification...",!
	.  if ^tptype="in0" do in0^dbfill("ver") q
	.  if ^tptype="in1" do in1^dbfill("ver") q
        ;
        w !,$s(ERR:"FAIL",1:"PASS")," from ",$t(+0)
        q
        ;

interfr1;
        w "Non-TP and TP-Rollback",!
	do ^job("thread1^interfer",5,""""_iterate_"""")
        quit

thread1(iterate);
	if jobindex=1 do job1^interfer(iterate)
	if jobindex=2 do job2^interfer(iterate)
	if jobindex=3 do job3^interfer(iterate)
	if jobindex=4 do job4^interfer(iterate)
	if jobindex=5 do job5^interfer(iterate)
	quit	

interfr2;
        w "Transaction Commit and TP-Rollback",!
	do ^job("thread2^interfer",6,""""_iterate_"""")
        quit

thread2(iterate);
	if jobindex=1 do job2^interfer(iterate)
	if jobindex=2 do job3^interfer(iterate)
	if jobindex=3 do job4^interfer(iterate)
	if jobindex=4 do job5^interfer(iterate)
	if jobindex=5 do job6^interfer(iterate)
	if jobindex=6 do job7^interfer(iterate)
	quit	

interfr3;
        w "non-TP and Transaction Commit and TP-Rollback",!
	do ^job("thread3^interfer",7,""""_iterate_"""")
        quit

thread3(iterate);
	if jobindex=1 do job1^interfer(iterate)
	if jobindex=2 do job2^interfer(iterate)
	if jobindex=3 do job3^interfer(iterate)
	if jobindex=4 do job4^interfer(iterate)
	if jobindex=5 do job5^interfer(iterate)
	if jobindex=6 do job6^interfer(iterate)
	if jobindex=7 do job7^interfer(iterate)
	quit	

job1(iterate)	;
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(1)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . do in0^dbfill("kill")
        . do in1^dbfill("kill")
        . do in0^dbfill("set")
        . do in1^dbfill("set")
	. S ^iterate(1)=loop
	q


job2(iterate);
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(2)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^dbfill("set")
	. do in1^dbfill("set")
        . TRollback
	. S ^iterate(2)=loop
	q

job3(iterate);
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(3)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^dbfill("kill")
	. do in1^dbfill("kill")
        . TRollback
	. S ^iterate(3)=loop
	q

job4(iterate);
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(4)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in1^dbfill("set")
	. do in0^dbfill("set")
        . TRollback
	. S ^iterate(4)=loop
	q

job5(iterate);
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(5)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in1^dbfill("kill")
	. do in0^dbfill("kill")
        . TRollback
	. S ^iterate(5)=loop
	q

job6(iterate)	;
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(6)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^dbfill("set")
	. do in1^dbfill("kill")
	. S ^tptype="in0"
	. TCOMMIT
	. S ^iterate(6)=loop
	q

job7(iterate)	;
        W "PID: ",$J,!
	SET $ZT="g ERROR^interfer"
	new loop
	L +^permit(7)
	F loop=1:1:iterate DO
	. w "Loop:",loop,!
        . Tstart ():serial
	. do in0^dbfill("kill")
	. do in1^dbfill("set")
	. S ^tptype="in1"
	. TCOMMIT
	. S ^iterate(7)=loop
	q

ERROR   SET $ZT=""
        IF $TLEVEL TROLLBACK
        ZSHOW "*"
        ZM +$ZS
