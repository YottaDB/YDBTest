;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Multi-region test with simplistic pseudo-bank thing
;
;	Global ACCT holds account balance.
;	Global JNL hold delta (transaction) amounts in history
;	Global ACNM hold name on account
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mrtst(jobcnt,trans)	;

	; Fire up some jobs to beat up database

	; Write $ZDate($Horolog,"24:60:SS")," Spawning tasks..",! 
	Write " Spawning tasks..",!
	Set output="mrtst.mjo0",error="mrtst.mje0"
	Open output:newversion,error:newversion
	Use output
	Set unix=$ZVersion'["VMS"
	; Write $ZDate($Horolog,"24:60:SS")," Main task started",! 
	Write "Main task started",!

	Lock +^TEST
	For I=1:1:jobcnt Do
	. If unix J @("job1^mrtst(trans,I):(output=""mrtst.mjo"_I_""":error=""mrtst.mje"_I_""")")
	. Else    J @("JOB1^MRTST(trans,I):(NODETACHED:STARTUP=""STARTUP.COM"":OUTPUT=""MRTST.MJO"_I_""":ERROR=""MRTST.MJE"_I_""")")

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
	; Write $ZDate($Horolog,"24:60:SS")," Releasing tasks and waiting..",! 
	Write "Releasing tasks and waiting..",!
	Use output
	Lock -^TEST		; Release all jobs waiting on gating lock

	; Wait a few more millibleems for all jobs to get started and aquire their sublocks
	Hang 10
	Lock +^TEST:18360	; Returns in 6 hours or when all processes finish

	Set PassFail=$Select($T:"PASS",1:"FAIL")
	If $Data(^ERROR)=0 Write PassFail," FROM ",$T(+0),!
	Else  Write "Fail from ",$T(+0),! Set PassFail="FAIL"
	; Write $ZDate($Horolog,"24:60:SS")," Main task ended",!
	Write "Main task ended",!
	Close output,error
	U 0
	; Write $ZDate($Horolog,"24:60:SS")," Test complete (",PassFail,")",!
	Write "Test complete (",PassFail,")",!
	Lock
	Quit

job1(trans,jobno)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," started .. waiting",! 
	Set ^ERROR(jobno)=0
	Set $ZTrap="goto ERROR"
	Set ^JOBSETUP(jobno)=1
	Lock +^TEST(jobno)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," released",! 
	For i=1:1:trans Do
	. Set acct=$Random(^ACCT(0))+1
	. Lock +^ACCT(acct)
	. Set delta=$Random(10000)-5000
	. Set name=^ACNM(acct)
	. Set balance=^ACCT(acct)+delta
	. Set jnlrec=^JNL(acct,0)
	. If jnlrec="" Do 
	. . Write "*** Error in update ",i,": Unable to locate global variable ^JNL(",acct,",0) -- bypassing update",!
	. . Write "*** ... Values are -- $Get: ",$Get(^JNL(acct,0)),", Reference: ",^JNL(acct,0),!
	. . Set ^ERROR=1
	. Else  Do
	. . Set jnlrec=jnlrec+1
	. . Set ^JNL(acct,0)=jnlrec
	. . Set ^JNL(acct,jnlrec)=delta
	. . Set ^ACCT(acct)=balance
	. . ; Write "    Account number ",acct," Name ",name," Transaction amount ",delta," Balance ",balance,!
	. Lock -^ACCT(acct)
	Write $ZDate($Horolog,"24:60:SS")," Job ",jobno," ended",! 
	Write !,"Pass from ",$T(+0)
	Kill ^ERROR(jobno)
	Quit		;rundown will clear the LOCK

ERROR	Set $ZTrap=""
	ZShow "*"
	ZM +$ZS
