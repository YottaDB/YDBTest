;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Multi-region tp test with simplistic pseudo-bank thing
;
;	Global ACCT holds account balance.
;	Global JNL hold delta (transaction) amounts in history
;	Global ACNM hold name on account
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mrtptst	;

	Set jobcnt=10
 	Set trans=1000

	; Fire up some jobs to beat up database

	Write " Spawning tasks and waiting..",! 
	Set output="mrtptst.mjo0",error="mrtptst.mje0"
	Open output:newversion,error:newversion
	Use output
	Set unix=$ZVersion'["VMS"
	Write $ZDate($Horolog,"24:60:SS")," Main task started",! 

	Lock +^TEST
	For I=1:1:jobcnt Do
	. If unix J @("job1^mrtptst(trans,I):(output=""mrtptst.mjo"_I_""":error=""mrtptst.mje"_I_""")")
	. Else    J @("JOB1^MRTPTST(trans,I):(NODETACHED:STARTUP=""STARTUP.COM"":OUTPUT=""MRTPTST.MJO"_I_""":ERROR=""MRTPTST.MJE"_I_""")")

	; Wait for jobs just started to flag their readiness to proceed, then let them all go
	; at once 
	Set jobsInitd=0
	For I=1:1 Do  Quit:jobsInitd
	. Set jobsSetup=0
	. For J=1:1:jobcnt Do  
	. . Set jobsSetup=jobsSetup+$Get(^JOBSETUP(J))
	. If jobsSetup=jobcnt Set jobsInitd=1 Quit
	. Hang 1

	; Wait one more millibleem for all jobs to get "hung" on their locks
	Hang 1

	Use 0
	Write "Releasing tasks and waiting..",! 
	Use output
	Lock -^TEST		; Release all jobs waiting on gating lock

	; Wait a few more millibleems for all jobs to get started and aquire their sublocks
	Hang 10
	Lock +^TEST:18360	; Returns in 6 hours or when all processes finish

	Set PassFail=$Select($T:"PASS",1:"FAIL")
	If $Data(^ERROR)=0 Write PassFail," FROM ",$T(+0),!
	Else  Write "Fail from ",$T(+0),! Set PassFail="FAIL"
	Write $ZDate($Horolog,"24:60:SS")," Main task ended",!
	Close output,error
	U 0
	Write " Test complete (",PassFail,")",!
	Lock
	Quit

job1(trans,jobno)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," started",! 
	Set ^ERROR(jobno)=0
 	Set $ZTrap="goto ERROR"
	Set ^JOBSETUP(jobno)=1
	Lock +^TEST(jobno)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," released",! 
	For i=1:1:trans Do
	. TStart ()
	. ;TStart
	. Set acct=$Random(^ACCT(0))+1
	. Set delta=$Random(10000)-5000
	. ;Lock +^ACCT(acct)
	. Set name=^ACNM(acct)
	. Set balance=^ACCT(acct)+delta
	. Set jnlrec=^JNL(acct,0)
	. If jnlrec="" Do 
	. . Write "*** Error in update ",i,": Unable to locate global variable ^JNL(",acct,",0) -- bypassing update",!
	. . Write "*** ... Values are -- $Get: ",$Get(^JNL(acct,0)),", Reference: ",^JNL(acct,0),!
	. . Set ^ERROR=1
	. . TCommit
	. Else  Do
	. . Set jnlrec=jnlrec+1
	. . Set ^JNL(acct,0)=jnlrec
	. . Set ^JNL(acct,jnlrec)=delta
	. . Set ^ACCT(acct)=balance
	. . TCommit
	. . ;Write "    Account number ",acct," Name ",name," Transaction amount ",delta," Balance ",balance,!
	. ;Lock -^ACCT(acct)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," ended",! 
	Write !,"Pass from ",$T(+0)
	Kill ^ERROR(jobno)
	Quit		;rundown will clear the LOCK

ERROR	Set $ZTrap=""
	ZShow "*"
	TRollback
	ZShow "*"
	ZM +$ZS
