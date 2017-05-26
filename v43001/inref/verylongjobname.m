imptp(jobcnt); Infinite loop multiprocess TP fill program
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
	;
	SET $ZT="SET $ZT="""" g ERROR^imptp"
	W " Main task started",! 
	;
	Set output="imptp.mjo0",error="imptp.mje0"
	Open output:newversion,error:newversion
	Use output
	; Must write PID to *.mjo files
	W "PID: ",$J,!
	Close output
	Set unix=$zv'["VMS"
	;
	;
	;   Precalculate primitive root for a prime and set it here
	SET ^prime=300007	;Precalculated
	SET ^root=3		;Precalculated
	;
	;
	; Initialization
	IF $DATA(^totaljob)=0 SET ^totaljob=jobcnt
	ELSE  IF ^totaljob'=jobcnt  w "Job number mismatch",!  q
	SET top=^prime\jobcnt
	SET timeout=jobcnt*jobcnt*top      ; an estimate of timeout
        IF timeout<30 SET timeout=30            ; Minimum timeout
        IF timeout>7200 SET timeout=7200        ; Will not run more than 2 hr
	SET ^endloop=0
	;
	L ^mainlock
	L +^permit
	F I=1:1:jobcnt D
	.  IF unix J @("tpjob^imptp(I,jobcnt,top):(output=""very_very_long_filename_job.mjo"_I_""":error=""very_very_long_filename_job.mje"_I_""")")
	.  Else  J @("tpjob^imptp(I,jobcnt,top):(STARTUP=""STARTUP.COM"":output=""very_very_long_filename_job.mjo"_I_""":error=""very_very_long_filename_job.mje"_I_""")")
	. H 3
	L -^permit
	H 0
	H jobcnt*jobcnt
	L +^permit:timeout
	W $S($T:"OK",1:"TEST-E-Timed out")," FROM ",$T(+0),!
	W " Main task ended",! 
	h 5	; Wait for all child to exit
	Q
tpjob(jobno,jobcnt,top)
	;
	SET $ZT="SET $ZT="""" g ERROR^imptp"
	SET istp=1
	IF $ztrnlnm("gtm_test_tp")="NON_TP"  SET istp=0  
	SET tptype="BA"
	IF $ztrnlnm("gtm_test_tptype")="ONLINE"  SET tptype="ONLINE"
	if istp=0 w "It is Non-TP",!
	else  w "It is TP",!
        W "PID: ",$J,!  
	;W "PID: ",$$FUNC^%DH($j),!
	Set unix=$zv'["VMS"
        IF 'unix DO
        .  SET pname="PNAME.JOB"_jobno
        .  OPEN pname:newversion  USE pname  WRITE $ZGETJPI("","PRCNAM"),!
        .  CLOSE pname
        ;
	;
	L +^permit(jobno)	; Wait until parent release ^permit
	;
	SET fltconst=3.14
	SET prime=^prime
	SET root=^root
	IF $GET(^tpnoiso)=1  view "NOISOLATION":"^a,^b,^c,^d,^e,^f,^g,^h,^i"       
	;
	SET nroot=1
	F J=1:1:jobcnt SET nroot=(nroot*root)#prime
	SET lasti=0
	IF $DATA(^lasti(jobno))=1 SET lasti=^lasti(jobno)
	; 
	; Initially we have followings:	
	; 	Job 1: I=w^0
	; 	Job 2: I=w^1
	; 	Job 3: I=w^2
	; 	Job 4: I=w^3
	; 	Job 5: I=w^4
	;	nroot = w^5 (all job has same value)
	SET I=1
	F J=2:1:jobno  SET I=(I*root)#prime
	F J=1:1:lasti  SET I=(I*nroot)#prime
	;
	;
	w "Job No:",jobno," Starting index:",lasti+1,!
	F cnt=lasti+1:1:top D  q:^endloop=1
	. SET subs=$$^genstr(I)
	. SET ^aa(subs)=subs_$J(subs,70) 
	. SET ^mm(subs)=subs_$J(subs,71) 
	. SET ^zz(subs)=subs_$J(subs,72) 
	. IF istp TStart ():(serial:transaction=tptype)
	. SET ^lasti(jobno)=cnt
	. SET ^a(subs)=$GET(^a(subs))_subs_$J(subs,80) 
	. SET ^b(subs)=$GET(^b(subs))_subs_$J(subs,79)
	. SET ^c(subs)=$GET(^c(subs))_subs_$J(subs,78)
	. SET ^d(subs)=$GET(^d(subs))_subs_$J(subs,77)
	. SET ^e(subs)=$GET(^e(subs))_subs_$J(subs,76)
	. SET ^f(subs)=$GET(^f(subs))_subs_$J(subs,75)
	. SET ^g(subs)=$GET(^g(subs))_subs_$J(subs,74)
	. SET ^h(subs)=$GET(^h(subs))_subs_$J(subs,73)
	. SET ^i(subs)=$GET(^i(subs))_subs_$J(subs,72)
	. SET ^adummy(subs)=$j(cnt,1+$r(50))
	. IF istp TCommit
	. F J=1:1:jobcnt D
        . . IF istp TStart ():(serial:transaction=tptype)
        . . SET ^a(subs,J)=$GET(^a(subs))_J
        . . SET ^b(subs,J)=$GET(^b(subs))_J
        . . SET ^c(subs,J)=$GET(^c(subs))_J
        . . SET ^d(subs,J)=$GET(^d(subs))_J
        . . SET ^e(subs,J)=$GET(^e(subs))_J
        . . SET ^f(subs,J)=$GET(^f(subs))_J
        . . SET ^g(subs,J)=$GET(^g(subs))_J
        . . SET ^h(subs,J)=$GET(^h(subs))_J
        . . SET ^i(subs,J)=$GET(^i(subs))_J
	. . if $r(10)=1 if $TRESTART>2  h 5
        . . IF istp TCommit 
        . IF istp TStart ():(serial:transaction=tptype)
	. KILL ^a(subs,1)
	. KILL ^b(subs,1)
	. KILL ^c(subs,1)
	. KILL ^d(subs,1)
	. KILL ^e(subs,1)
	. KILL ^f(subs,1)
	. KILL ^g(subs,1)
	. KILL ^h(subs,1)
	. KILL ^i(subs,1)
        . IF istp TCommit 
	. SET ^ndxarr(jobno,cnt)=I
	. KILL ^zz(subs)
	. SET I=(I*nroot)#prime
	w "Job No:",jobno," End index:",cnt,!
	L -^permit(jobno)
	Q		
ERROR	ZSHOW "*"
	IF $TLEVEL TROLLBACK
	q
