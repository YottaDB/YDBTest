;	Usage:
;	1) Test system mostly calls imptp.csh or imptp.com to run this routine. Caller sets the environment as appropriate
;	2) To run it in background, just call ^imptp(number of jobs)
;	3) To run in foreground with fixed number of tranasactions, 
;		set ^%imptp("top") to desired value, and set jmaxwait for timeout
;	Known limitations:
;	-----------------
;	1) checkdb will error out if gtcm and crash test is used
;	2) for non-tp and crash this will still do some TP updates
;	3) skipreg is allowed only for crash test. For now it skips only HREG. imptp.m will still fill HREG. 
;		checkdb/extract/dbcheck need to take care of skipping the region.
;	4) can be invoked concurrently with different gtm_test_dbfillid but checkdb should be called once for each value
;
v4imptp(jobcnt); Infinite multiprocess TP or non-TP database fill program
	;
	set $ZT="set $ZT="""" g ERROR^v4imptp"
	;
	w "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	w "$zro=",$zro,!
	; Note that we immediately return from parent. 
	; So no need to kill it for crash tests. So, imptp.mjo0 is not created.
        w "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	if $zv["VMS" w "Process Name: ",$ZGETJPI("","PRCNAM"),!
	;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Start processing test system paramters
	;
	; istp = 0 non-tp
	; istp = 1 TP
	; istp = 2 ZTP
	if $ztrnlnm("gtm_test_tp")="NON_TP"  DO
	.  set istp=0  
	.  W "It is Non-TP",!  
	else  DO
	.  if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
	.  else  set istp=1  write "It is TP",!
	set ^%imptp("istp")=istp
	;
	if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp("tptype")="ONLINE"
	else  set ^%imptp("tptype")="BATCH"
	;
	; Randomly 50% time use noisolation for TP
	if (istp=1)&($random(2)=1) set ^%imptp("tpnoiso")=1
	else  set ^%imptp("tpnoiso")=0
	;
	; Randomly 50% time use optimization for redundant sets
	;if ($random(2)=1) set ^%imptp("dupset")=1
	;else  set ^%imptp("dupset")=0
	set ^%imptp("dupset")=0
	;
	set ^%imptp("crash")=+$ztrnlnm("gtm_test_crash")
	;
	set ^%imptp("gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
	;
	set ^%imptp("skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
	;
	set jobid=$ztrnlnm("gtm_test_jobid")
	;
	set fillid=+$ztrnlnm("gtm_test_dbfillid")
	set ^%imptp("fillid")=fillid
	;
	if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
	else  if ^%imptp(fillid,"totaljob")'=jobcnt  w "Job number mismatch",!  zwr ^%imptp  h
	;
	;
	; End of processing test system paramters
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;   This program fills database randomly using primitive root of a field. 
	;   Say, w is the primitive root and we have 5 jobs
	;   Job 1 : Sets index w^0, w^5, w^10 etc.
	;   Job 2 : Sets index w^1, w^6, w^11 etc.
	;   Job 3 : Sets index w^2, w^7, w^12 etc.
	;   Job 4 : Sets index w^3, w^8, w^13 etc.
	;   Job 5 : Sets index w^4, w^9, w^14 etc.
	;   In above example nroot = w^5
	;   In above example root =  w
	;   Precalculate primitive root for a prime and set them here
	set ^%imptp("prime")=50000017	;Precalculated
	set ^%imptp("root")=5		;Precalculated
	set ^endloop(fillid)=0	;To stop infinite loop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;
	set ^%imptp("jsyncnt")=0		; To count number of processes are ready to be killed by crash scripts
	; When rsh command exits after starting remote jobs, nodetahced child processes will also die
	; So for gtcm_gnp test or multi_machine VMS tests we must use detach
	; If the terminal is gone after starting child processes, all child can also die
	; So it is safer to start detached job always 
	set jdetach=1		; VMS will start detached jobs
	if ($data(jmaxwait))=0 set jmaxwait=0	; Child process will continue in background. So do not wait, just return.
	do ^job("impjob^v4imptp",jobcnt,"""""")
	;
	; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	set timeout=600	; 10 minutes to start and reach the sync point for kill
	for i=1:1:600 h 1 q:^%imptp("jsyncnt")=^%imptp(fillid,"totaljob")
	if ^%imptp("jsyncnt")<^%imptp(fillid,"totaljob") do
	. write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
	. zwr ^%imptp
	;
	w "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q
	;
impjob;
	set inc=+$ztrnlnm("gtm_test_wait_factor")
	set $ZT="set $ZT="""" g ERROR^v4imptp"
	w "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	w "$zro=",$zro,!
	;
	set jobno=jobindex	; Set by job.m
	set fillid=^%imptp("fillid")
	set jobcnt=^%imptp(fillid,"totaljob")
	set prime=^%imptp("prime")
	set root=^%imptp("root")
	set top=+$GET(^%imptp("top"))
	if top=0 set top=prime\jobcnt
	set istp=^%imptp("istp")
	set tptype=^%imptp("tptype")
	set tpnoiso=^%imptp("tpnoiso")
	set dupset=^%imptp("dupset")
	set skipreg=^%imptp("skipreg")
	set crash=^%imptp("crash")
	set gtcm=^%imptp("gtcm")
	set zwrcmd="zwr jobno,istp,tptype,tpnoiso,dupset,skipreg,crash,gtcm,fillid"
	write zwrcmd,!
	xecute zwrcmd
	;
        W "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	If $zv["VMS" DO ^jobname(jobno)
	;
	L +^%imptp("jsyncnt")  set ^%imptp("jsyncnt")=^%imptp("jsyncnt")+1  L -^%imptp("jsyncnt")
	;
	; lfence is used for the fence type of last segment of updates of *ndxarr at the end
	; For non-tp and crash test meaningful application checking is very difficult
	; So at the end of the iteration TP transaction is used
	; For gtcm we cannot use TP at all, because it is not supported. 
	; We cannot do crash test for gtcm.
	set lfence=istp			
	if (istp=0)&(crash=1) set lfence=1	; TP fence 
	if gtcm=1 set lfence=0			; No fence
	;
	if tpnoiso do tpnoiso^v4imptp
	if dupset view "GVDUPSETNOOP":1
	;
	set fltconst=3.14
	set nroot=1
	for J=1:1:jobcnt set nroot=(nroot*root)#prime
	set lasti=0
	if $DATA(^lasti(fillid,jobno))=1 set lasti=^lasti(fillid,jobno)
	; 
	; Initially we have followings:	
	; 	Job 1: I=w^0
	; 	Job 2: I=w^1
	; 	Job 3: I=w^2
	; 	Job 4: I=w^3
	; 	Job 5: I=w^4
	;	nroot = w^5 (all job has same value)
	set I=1
	for J=2:1:jobno  set I=(I*root)#prime
	for J=1:1:lasti  set I=(I*nroot)#prime
	;
	;
	w "Starting index:",lasti+1,!
	for loop=lasti+1:1:top D  q:^endloop(fillid)=1
	. set subs=$$^genstr(I)			; I to subs  has one-to-one mapping
	. set val=$$^genstr(loop)		; loop to val has one-to-one mapping
	. set val800=$j(val,800)
	. ;
	. if istp=1 tstart *:(serial:transaction=tptype)
	. if istp=2 ztstart
	. set ^a(fillid,subs)=val
	. if ((istp=1)&(crash)) do
	. . set rndm=$r(10)
	. . if rndm=1 if $TRESTART>2  do noop^v4imptp	; Just randomly hold crit for long time
	. . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
	. . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow
	. set ^b(fillid,subs)=val
	. set ^c(fillid,subs)=val
	. set ^d(fillid,subs)=val
	. set ^e(fillid,subs)=val
	. set ^f(fillid,subs)=val
	. set ^g(fillid,subs)=val
	. set ^h(fillid,subs)=val
	. set ^i(fillid,subs)=val
	. set ^j(fillid,I)=val
	. set ^j(fillid,I,I)=val
	. set ^j(fillid,I,I,subs)=val
	. if istp'=0 set ^lasti(fillid,jobno)=loop
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ;
	. set ^antp(fillid,subs)=val
	. set ^bntp(fillid,subs)=val
	. set ^cntp(fillid,subs)=val
	. set ^dntp(fillid,subs)=val
	. ;
	. if istp=1 tstart ():(serial:transaction=tptype)
	. if istp=2 ztstart
	. set ^entp(fillid,subs)=val
	. set ^fntp(fillid,subs)=val
	. set ^gntp(fillid,subs)=val800
	. set ^hntp(fillid,subs)=val800
	. set ^intp(fillid,subs)=val800
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ;
	. for J=1:1:jobcnt D
	. . set valj=val_J
	. . ;
        . . if istp=1 tstart ():(serial:transaction=tptype)
	. . if istp=2 ztstart
        . . set ^a(fillid,subs,J)=valj
        . . set ^b(fillid,subs,J)=valj
        . . set ^c(fillid,subs,J)=valj
        . . set ^d(fillid,subs,J)=valj
        . . set ^e(fillid,subs,J)=valj
        . . set ^f(fillid,subs,J)=valj
        . . set ^g(fillid,subs,J)=valj
        . . set ^h(fillid,subs,J)=valj
        . . set ^i(fillid,subs,J)=valj
        . . if istp=1 tcommit 
	. . if istp=2 ztcommit
	. . ;
	. ;
        . if istp=1 tstart ():(serial:transaction=tptype)
	. if istp=2 ztstart
	. if ((istp=1)&(crash)) do
	. . set rndm=$r(10)
	. . if rndm=1 if $TRESTART>2  do noop^v4imptp	; Just randomly hold crit for long time
	. . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time
	. kill ^a(fillid,subs,1)
	. kill ^b(fillid,subs,1)
	. kill ^c(fillid,subs,1)
	. kill ^d(fillid,subs,1)
	. kill ^e(fillid,subs,1)
	. kill ^f(fillid,subs,1)
	. kill ^g(fillid,subs,1)
	. kill ^h(fillid,subs,1)
	. kill ^i(fillid,subs,1)
        . if istp=1 tcommit 
	. if istp=2 ztcommit
	. ;
        . if istp=1 tstart ():(serial:transaction=tptype)
	. if istp=2 ztstart
	. zkill ^j(fillid,I)
	. zkill ^j(fillid,I,I)
        . if istp=1 tcommit 
	. if istp=2 ztcommit
	. ;
	. kill ^a(fillid,subs,1)	; This results nothing
	. kill ^antp(fillid,subs)
	. kill ^bntp(fillid,subs)
	. zkill ^b(fillid,subs,1)	; This results nothing
	. zkill ^cntp(fillid,subs)
	. zkill ^dntp(fillid,subs)
	. if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP.
	. ;
	. ; ^cntloop and ^cntseq exersize contention in CREG (regions > 3) or DEFAULT (regions <= 3)
        . if istp=1 tstart (I):(serial:transaction=tptype)
	. if istp=2 ztstart
	. set ^cntloop(fillid)=$GET(^cntloop(fillid))+1			; May cause duplicate sets for non-tp and ztp
	. set ^cntseq(fillid)=$GET(^cntseq(fillid))+(13+jobcnt)		; May cause duplicate sets for non-tp and ztp
	. if istp=1 tcommit
	. if istp=2 ztcommit
	. ;
	. if lfence=1 tstart ():(serial:transaction=tptype)
	. if lfence=2 ztstart
	. set ^andxarr(fillid,jobno,loop)=I
	. set ^bndxarr(fillid,jobno,loop)=I
	. set ^cndxarr(fillid,jobno,loop)=I
	. set ^dndxarr(fillid,jobno,loop)=I
	. set ^endxarr(fillid,jobno,loop)=I
	. set ^fndxarr(fillid,jobno,loop)=I
	. set ^gndxarr(fillid,jobno,loop)=I
	. set ^hndxarr(fillid,jobno,loop)=I
	. set ^indxarr(fillid,jobno,loop)=I
	. if istp=0 set ^lasti(fillid,jobno)=loop
	. if lfence=1 tcommit
	. if lfence=2 ztcommit
	. set I=(I*nroot)#prime
	. if inc'=0  hang inc	; sleep if needed
	;
	; End For Loop
	;
	w "End index:",loop,!
	w "Job completion successful",!
	w "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	Q		
noop;
	; Just to stress memory
	new index,var
	set ^dummynoop(fillid,jobno,loop,"start",$j,$h)=$ZGETJPI(0,"CPUTIM")
	for index=1:1:1000 DO
	. set var(index)=$j(index,2048)_$h
	K index,var
	h 1
	set ^dummynoop(fillid,jobno,loop,"end",$j,$h)=$ZGETJPI(0,"CPUTIM")
	q
tpnoiso;
	view "NOISOLATION":"^a,^b,^c,^d,^e,^f,^g,^h,^i,^j"       
	w "$view(""NOISOLATION"",""^a"")=",$view("NOISOLATION","^a"),!
	w "$view(""NOISOLATION"",""^b"")=",$view("NOISOLATION","^b"),!
	w "$view(""NOISOLATION"",""^c"")=",$view("NOISOLATION","^c"),!
	w "$view(""NOISOLATION"",""^d"")=",$view("NOISOLATION","^d"),!
	w "$view(""NOISOLATION"",""^e"")=",$view("NOISOLATION","^e"),!
	w "$view(""NOISOLATION"",""^f"")=",$view("NOISOLATION","^f"),!
	w "$view(""NOISOLATION"",""^g"")=",$view("NOISOLATION","^g"),!
	w "$view(""NOISOLATION"",""^h"")=",$view("NOISOLATION","^h"),!
	w "$view(""NOISOLATION"",""^i"")=",$view("NOISOLATION","^i"),!
	w "$view(""NOISOLATION"",""^j"")=",$view("NOISOLATION","^j"),!
	q
	;
ERROR	ZSHOW "*"
	if $TLEVEL TROLLBACK
	q
