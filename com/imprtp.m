imprtp	; ; ; Test of random transaction interference
	;
	SET $ZT="g ERROR^imprtp"
	w "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	;
	; Note that we immediately return from parent. 
	; So no need to kill it for crash tests. So, imprtp.mjo0 is not created.
        w "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	if $zv["VMS" w "Process Name: ",$ZGETJPI("","PRCNAM"),!
	;
	set parms=$ZTRNLNM("gtm_test_parms")
	set maxdim=+$ztrnlnm("gtm_test_maxdim")  
	W "DEBUG:parms=",parms,!
	W "DEBUG:maxdim=",maxdim,!
	if maxdim=0 W "TEST-E-imprtp Improper gtm_test_maxdim!!!",!  h
	SET fjob=$P(parms,",",1)
	SET endjob=$P(parms,",",2)
	if fjob=0 W "TEST-E-imprtp Improper gtm_test_parms!!!",!  h
	if endjob=0 W "TEST-E-imprtp Improper gtm_test_parms!!!",!  h
	if $data(iterate)=0 SET iterate=100000
	FOR I=1:1:maxdim SET ^ndx(I)=0
	SET jobid=$ZTRNLNM("gtm_test_jobid")
	SET jobcnt=endjob-fjob+1
	SET ^iterate=iterate
	SET ^maxdim=maxdim
	SET ^fjob=fjob
	SET ^totaljob=jobcnt
	SET ^endloop=0
	SET ^jsyncnt=0		; To count number of processes are ready to be killed by crash scripts
	set jmaxwait=0		; Child process will continue in background. So do not wait, just return.
	do ^job("imprjob^imprtp",jobcnt,"""""")
	;
	; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	set timeout=300	; 5 minutes to start and reach the sync point for kill
	for i=1:1:timeout h 1 q:^jsyncnt=^totaljob
	if ^jsyncnt<^totaljob  w "TEST-E-imptp.m time out for ^jsyncnt after ",timeout," seconds",!," ^jsyncnt=",^jsyncnt," ^totaljob=",^totaljob,!  
	;
	w "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Quit

imprjob;
	SET $ZT="g ERROR^imprtp"
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	SET jobno=jobindex+^fjob-1
	SET jobcnt=^totaljob
	If $zv["VMS" DO ^jobname(jobno)
	;
	L +^jsyncnt  SET ^jsyncnt=^jsyncnt+1  L -^jsyncnt
	;
	SET jname="job"_jobno_"("_^iterate_","_^maxdim_")"
	d @jname
	w "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q

job1(iterate,maxdim);
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=1
	. do in2^npfill("set",loop+1#10+1,thisi)
        . TROLLBACK
	. S ^lasti(1)=loop
	q

job2(iterate,maxdim);
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=0
	. do in2^npfill("kill",loop+2#10+1,thisi)
        . TROLLBACK
	. S ^lasti(2)=loop
	q

job3(iterate,maxdim);
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=0
	. do in2^npfill("kill",loop+3#10+1,thisi)
        . TCOMMIT
	. S ^lasti(3)=loop
	q

job4(iterate,maxdim);
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=1
	. do in2^npfill("set",loop+4#10+1,thisi)
        . TCOMMIT
	. S ^lasti(4)=loop
	q

job5(iterate,maxdim)	;
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=0
	. do in2^npfill("kill",loop+5#10+1,thisi)
	. TCOMMIT
	. S ^lasti(5)=loop
	q
	;
job6(iterate,maxdim)	;
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=1
	. do in2^npfill("set",loop+6#10+1,thisi)
	. TCOMMIT
	. S ^lasti(6)=loop
	q
	;

job7(iterate,maxdim)	;
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
	. TStart ():(serial:transaction="BATCH")
	. SET ^ndx(thisi)=1
	. do in2^npfill("kill",loop+7#10+1,thisi)
	. do in2^npfill("set",loop+7#10+1,thisi)
	. TCOMMIT
	. S ^lasti(7)=loop
	q

job8(iterate,maxdim)	;
	new loop
	F loop=1:1:iterate DO  q:^endloop=1
	. SET thisi=$r(maxdim)  
        . do in2^npfill("kill",(loop#10)+1,thisi)
        . do in2^npfill("set",(loop#10)+1,thisi)
	. SET ^ndx(thisi)=1
	. S ^lasti(8)=loop
	q


ERROR   ;	
	SET $ZT=""
        ZSHOW "*"
        IF $TLEVEL TROLLBACK
	Q
