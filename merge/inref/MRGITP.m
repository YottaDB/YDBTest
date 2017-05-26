MRGITP	; ; ; Test of random transaction interference
	;
	;
	SET $ZT="g ERROR^MRGITP"
	Set output="MRGITP.mjo0",error="MRGITP.mje0"
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J
        Close output
	;
	set parms=$ZTRNLNM("gtm_test_parms")
	set maxdim=+$ztrnlnm("gtm_test_maxdim")  
	W "DEBUG:parms=",parms,!
	W "DEBUG:maxdim=",maxdim,!
	if maxdim=0 W "TEST-E-MRGITP Improper gtm_test_parms!!!",!  Q
	SET fjob=$P(parms,",",1)
	SET endjob=$P(parms,",",2)
	if fjob=0 W "TEST-E-MRGITP Improper gtm_test_maxdim!!!",!  Q
	if endjob=0 W "TEST-E-MRGITP Improper gtm_test_maxdim!!!",!  Q
	i '$d(act) n act s act="zshow"
	SET ^endloop=0
	if $data(iterate)=0 SET iterate=20
	for loop=1:1:maxdim do in3^nindfill("set",1,loop)
	;
	Set ITEM="MRGITP Test",ERR=0,unix=$zv'["VMS"
	w ITEM,!
	SET jobcnt=endjob-fjob+1
	SET ^iterate=iterate
	SET ^maxdim=maxdim
	SET ^fjob=fjob
	SET ^totaljob=jobcnt
	SET ^endloop=0
	SET ^killsync=0		; To count number of processes are ready to be killed by crash scripts
	SET jmaxwait=7200	; This parent waits for child processes to finish in 2 hr
	w "Start set/kill...",!
	do ^job("mrgjob^MRGITP",jobcnt,"""""")
	;
	; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	set timeout=300	; 5 minutes to start and reach the sync point for kill
	for i=1:1:300 h 1 q:^killsync=^totaljob
	if ^killsync<^totaljob  w "TEST-E-imptp.m time out for ^killsync after ",timeout," seconds",!," ^killsync=",^killsync," ^totaljob=",^totaljob,!  
	;
	for loop=1:1:maxdim do in3^nindfill("ver",1,loop)
	K ^g,^h
	M ^g=^gnew,^h=^hnew
	K ^gnew,^hnew
	for loop=1:1:maxdim do in3^nindfill("ver",1,loop)
	M ^a=^new3a,^b=^new3b,^c=^new3c,^d=^new3d
	K ^new3a,^new3b,^new3c,^new3d
	for loop=1:1:maxdim do in3^nindfill("ver",1,loop)
	;
	Quit
	;
	;
mrgjob;
	SET $ZT="g ERROR^MRGITP"
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	SET jobno=jobindex+^fjob-1
	SET jobcnt=^totaljob
	If $zv["VMS" DO ^jobname(jobno)
	;
	L +^killsync  SET ^killsync=^killsync+1  L -^killsync
	;
	SET jname="job"_jobno_"("_^iterate_","_^maxdim_")"
	d @jname
	w "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q

	;
job1(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
        . TSTART (c,d):serial
	. FOR ind2=1:1:maxdim  DO
	. . S nind2=$O(^a(nind2))  
	. . M a("MERGE",nind2)=^a(nind2)
	. . M b("MERGE",nind2)=^b(nind2)
	. M ^a=a("MERGE")
	. M ^b=b("MERGE")
	. M c("我能吞下玻璃而不伤身体"_mypid)=^c
	. M d("我能吞下玻璃而不伤身体"_mypid)=^d
        . TSTART ():serial
	. K ^c,^d
	. M ^c=c("我能吞下玻璃而不伤身体"_mypid),^d=d("我能吞下玻璃而不伤身体"_mypid)
        . TCOMMIT
	. M ^gnew=^g,^hnew=^h
        . TCOMMIT
	. S ^lasti(1)=loop
	q
job2(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
        . TSTART (c,d):serial
	. FOR ind2=1:1:maxdim  DO
	. . S nind2=$O(^a(nind2))  
	. . M ^new2a("MERGE",nind2)=^a(nind2)
	. . M ^new2b("MERGE",nind2)=^b(nind2)
	. M ^new2c("我能吞下玻璃而不伤身体"_mypid)=^c
	. M ^new2d("我能吞下玻璃而不伤身体"_mypid)=^d
        . TSTART ():serial
	. K ^c,^d
	. M ^c=^new2c("我能吞下玻璃而不伤身体"_mypid),^d=^new2d("我能吞下玻璃而不伤身体"_mypid)
        . TCOMMIT
        . TCOMMIT
	. S ^lasti(2)=loop
	q
	;
job3(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
        . TSTART ():serial
	. M ^new3a=^a,^new3b=^b,^new3c=^c,^new3d=^d
	. K ^a,^b,^c,^d
	. M ^a=^new3a,^b=^new3b,^c=^new3c,^d=^new3d
        . TCOMMIT
	. S ^lasti(3)=loop
	q
	;
job4(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
        . TSTART (a,b,c,d):serial
	. M a=^a,b=^b,c=^c,d=^d
	. K ^a,^b,^c,^d
	. M ^a=a,^b=b,^c=c,^d=d
        . TCOMMIT
	. S ^lasti(4)=loop
	q
	;
job5(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
	. SET rest=0
        . TSTART (a,b,c,d):serial
	. M a=^a,b=^b,c=^c,d=^d,e=^e,f=^f,g=^g,h=^h
	. K ^a,^b,^c,^d,^e,^f,^g,^h
	. M newvar("a")=a,newvar("b")=b,newvar("c")=c,newvar("d")=d
	. M newvar("e")=e,newvar("f")=f,newvar("g")=g,newvar("h")=h
	. M ^a=newvar("a"),^b=newvar("b"),^c=newvar("c"),^d=newvar("d")
	. M ^e=newvar("e"),^f=newvar("f"),^g=newvar("g"),^h=newvar("h")
	. K newvar,a,b,c,d
	. TCOMMIT
	. S ^lasti(5)=loop
	q
	;
job6(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
	. SET nind2=""
	. SET rest=0
        . TSTART (a,b,c,d):serial
	. M a=^a,b=^b,c=^c,d=^d,e=^e,f=^f,g=^g,h=^h
	. K ^a,^b,^c,^d,^e,^f,^g,^h
	. M newvar("a")=a,newvar("b")=b,newvar("c")=c,newvar("d")=d
	. M newvar("e")=e,newvar("f")=f,newvar("g")=g,newvar("h")=h
	. M ^a=newvar("a"),^b=newvar("b"),^c=newvar("c"),^d=newvar("d")
	. M ^e=newvar("e"),^f=newvar("f"),^g=newvar("g"),^h=newvar("h")
	. K newvar,a,b,c,d
	. if $TRESTART<4 TROLLBACK
	. else  TCOMMIT
	. S ^lasti(6)=loop
	q
	;
job7(iterate,maxdim);
	SET $ZT="g ERROR^MRGITP"
	SET mypid=$J
	F loop=1:1:iterate DO  q:^endloop=1
        . TSTART ():serial
	. do in3^nindfill("kill",3,loop)
	. do in1^nindfill("set",3,loop)
	. TROLLBACK
        . TSTART ():serial
	. do in1^nindfill("kill",3,loop)
	. do in3^nindfill("set",3,loop)
	. TCOMMIT
	. S ^lasti(7)=loop
	q
	;
ERROR   ;	
	SET $ZT=""
        ZSHOW "*"
        ZM +$ZS
        IF $TLEVEL TROLLBACK
	Q
