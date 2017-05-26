filltp(jobcnt); Infinite loop multiprocess TP fill program
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
	Set output="filltp.mjo0",error="filltp.mje0"
	Open output:newversion,error:newversion
	Use output
	; Must write PID to *.mjo files
	W "PID: ",$J,!
	Close output
	Set unix=$zv'["VMS"
	;
	;   Precalculate primitive root for a prime and set it here
	SET ^prime=300007	;Precalculated
	SET ^root=3		;Precalculated
	;
	;
	; Do some initialization
	W " Main task started",! 
	if $DATA(^totaljob)=0 SET ^totaljob=jobcnt
	else  if ^totaljob'=jobcnt  w "Job number mismatch",! q
	SET ^endloop=0
	if $DATA(top)=0 SET top=50000
	if top>(^prime\jobcnt)  set top=^prime\jobcnt   
        SET timeout=jobcnt*jobcnt*top 		; an estimate of timeout
        if timeout<60 SET timeout=60		; Minimum timeout
        if timeout>7200 SET timeout=7200	; Will not run more than 2 hr
	;
	L +^permit
	F I=1:1:jobcnt D
	. IF unix J @("tpjob^filltp(I,jobcnt,top):(output=""filltp.mjo"_I_""":error=""filltp.mje"_I_""")")
	. Else  J @("tpjob^filltp(I,jobcnt,top):(STARTUP=""STARTUP.COM"":output=""filltp.mjo"_I_""":error=""filltp.mje"_I_""")")
	. H 2
	L -^permit
	H 0
	H 5
	L +^permit:timeout
	W $S($T:"OK",1:"Timed out")," FROM ",$T(+0),!
	W " Main task ended",! 
	h 5	; Wait for all child to exit
	Q
tpjob(jobno,jobcnt,top)
	;
	; Must write PID to *.mjo files
	W "PID: ",$J,!
	SET $ZT="g ERROR"
	;
	L +^permit(jobno)	; Wait until parent release ^permit
	;
	SET prime=^prime		;Precalculated
	SET root=^root			;Precalculated
	;
	SET nroot=1
	F J=1:1:jobcnt SET nroot=(nroot*root)#prime
	SET lasti=0
	if $DATA(^lasti(jobno))=1 SET lasti=^lasti(jobno)
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
	. SET ^aa(I)=I_$J(I,70) 
	. SET ^mm(I)=I_$J(I,71) 
	. SET ^zz(I)=I_$J(I,72) 
	. TStart ():Serial
	. SET ^lasti(jobno)=cnt
	. SET ^a(I)=$GET(^a(I))_I_$J(I,80) 
	. SET ^b(I)=$GET(^b(I))_I_$J(I,79)
	. SET ^c(I)=$GET(^c(I))_I_$J(I,78)
	. SET ^d(I)=$GET(^d(I))_I_$J(I,77)
	. SET ^e(I)=$GET(^e(I))_I_$J(I,76)
	. SET ^f(I)=$GET(^f(I))_I_$J(I,75)
	. SET ^g(I)=$GET(^g(I))_I_$J(I,74)
	. SET ^h(I)=$GET(^h(I))_I_$J(I,73)
	. SET ^i(I)=$GET(^i(I))_I_$J(I,72)
	. TCommit
	. F J=1:1:jobcnt D
        . . TStart ():Serial
        . . SET ^a(I,J)=$GET(^a(I))_J
        . . SET ^b(I,J)=$GET(^b(I))_J
        . . SET ^c(I,J)=$GET(^c(I))_J
        . . SET ^d(I,J)=$GET(^d(I))_J
        . . SET ^e(I,J)=$GET(^e(I))_J
        . . SET ^f(I,J)=$GET(^f(I))_J
        . . SET ^g(I,J)=$GET(^g(I))_J
        . . SET ^h(I,J)=$GET(^h(I))_J
        . . SET ^i(I,J)=$GET(^i(I))_J
        . . TCommit 
        . TStart ():Serial
	. KILL ^a(I,1)
	. KILL ^b(I,1)
	. KILL ^c(I,1)
	. KILL ^d(I,1)
	. KILL ^e(I,1)
	. KILL ^f(I,1)
	. KILL ^g(I,1)
	. KILL ^h(I,1)
	. KILL ^i(I,1)
        . TCommit 
	. KILL ^zz(I)
	. SET I=(I*nroot)#prime
	w "Job No:",jobno," End index:",cnt,!
	L -^permit(jobno)
	Q		
ERROR	SET $ZT=""
	IF $TLEVEL TROLLBACK
	ZSHOW "*"
	ZM +$ZS
