;
; Error thrown during job interrupt should not be rethrown after jobinterrupt frame
; resumes (C9K10-003334).
;
; Test methodology: Drive a job interrupt in the main routine to validate that the job
; interrupter is alive. Then make a call that bumps to a new stack frame and installs
; a $ZINTERRUPT handler that either itself or something it calls gets an error. A simpler
; loop then waits for the job interrupt to occur. The handler driven for the error should
; not clear $ECODE so that when the zinterrupt frame is unwound, the error is still not
; handled. But the error handling should stop at that point and NOT raise the $ZINTERRUPT
; error in the interrupted frame. If the error is still unhandled at that point, the
; unhandled error should show up in the system log.
;
	Set ourlvl=$ZLevel
	Set loopcntr=0,^done=0,zintcnt=0
	Set $ETrap="Do Error^C9K10003334"
	Set $ZInterrupt="ZGoto:loopcntr>0 ourlvl:Step2^C9K10003334"
	Set jmaxwait=0
	Do ^job("intrproc^C9K10003334",1,$Job)

	For  Do
	. If loopcntr>999999999 Set loopcntr=1 ZGoto ourlvl:Done^C9K10003334	; If waited long enuf for interrupt (fail)
	. Set loopcntr=loopcntr+1
	. 
	;
	; Continuation point once the initial job interrupt has been received
	;
Step2	; Interrupt sending process is running - try it out on 
	Do jobintr2	; Spend some time in an external routine waiting for next job interrupt which drives an
	   		; unknown handler causing an error.
	;
	; When complete or timed out of initial loop, come here to cleanup.
	;
Done
	Do:(0=^done)
	. Write "Setting ^done at Done^C9K10003334",!
	. Set ^done=1
	Do wait^job
	Set pass=((1<loopcntr)&(0<zintcnt))
	Write "D9K07002782 ",$Select(pass:"PASS",1:"FAIL"),!
	ZWrite:'pass
	Quit

	;
	; Simplistic $ETRAP handler for entire test.
	;
Error
	Write "Setting ^done in Error handler",!
	Set ^done=1
	Set $ETrap=""
	ZShow "*"
	Halt

;
; Routine that gets control once the interrupt sending process has been established.
; We reset the $ZINTERRUPT string to contain something that will give an error. The 
; error handler won't clear $ECODE so the error gets rethrown here which has caused
; problems in the past.
;
jobintr2
	New i
	Set $ETrap=""
	Set $ZInterrupt="Set x=$Increment(zintcnt) Set $ZInterrupt="""" Set ^done=1 Do nonexistantrtn"
	For i=1:1:360 Quit:(0<zintcnt)  Hang 1	   ; Wait max of 6 mins
	Write:(1=^done) "Setting ^done in $ZInterrupt in jobintr2",!
	Quit

;
; Interrupt process sends job interrupts to the main routine.
;
intrproc(pid)
	Set logname="intrptrslt.log"
	ZSystem "rm -f "_logname_" >& /dev/null"
	Hang 4		; Let parent get going
	For  Quit:^done  Do
	. ZSystem "$gtm_dist/mupip intrpt "_pid_" >>& "_logname
	. If $ZSigproc(pid,0)'=0 Set ^done=1	; Note $ZSystem is not set properly by mupip intrpt
	. Else  Hang .1
	Quit
