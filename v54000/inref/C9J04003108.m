; C9J04003108.m: Test $ECODE save/restore across a $ZINTERRUPT

  	Set maxloop=1200     ; With .1 second sleeps, this is 2 minutes

        ; First put something into $ECODE. Need to be in a handler to see that so test continues there..
	Set $ETrap="Do contmain"
	Set x="abc",y=@x
	w "premature",!
 	q
contmain
	Set $Etrap="";
	Do contmain2	; Give $Stack something to look at
	Quit

contmain2
	Set $ETrap=""
	Set SVecode=$ECode,SVzstatus=$ZStatus,SVstkdpth=$Stack(-1),SVstkcmd=$Stack(0)
	For i=1:1:SVstkdpth Set SVstk(i)=$Stack(i,"PLACE")
	If SVstkdpth'>1 Write "FAIL: Insufficient stack depth",! ZShow "*" Halt

	; Now send ourselves a $ZInterrupt..
	Set $ZInterrupt="Do zintr"
	Set j=1
	If $ZVersion["VMS" Set xx=$ZSIGPROC($Job,16)
	Else  ZSystem "$gtm_dist/mupip intr "_$Job_">& /dev/null"
	For i=j:1:maxloop Do
	. Hang .1	 ; 2 minute loop to wait for interruption, cut short by interrupt.
	If i=1200 Write "FAIL -- interrupt did not arrive",! ZShow "*" Halt
	; We were interrupted, verify things are back where they should be.
	Set err=0
	If $ECode'=SVecode Write "FAIL: $ECode expected/actual: ",SVecode,"/",$ECode,! If $Incr(err)
	If $ZStatus'=SVzstatus Write "FAIL: $ZStatus expected/actual: ",SVzstatus,"/",$ZStatus,! If $Incr(err)
	If $Stack(0)'=SVstkcmd Write "FAIL: $Stack(0) command expected/actual: ",SVstkcmd,"/",$Stack(0),! If $Incr(err)
	If $Stack(-1)'=SVstkdpth Write "FAIL: $Stack(-1) depth expected/actual: ",SVstkdpth,"/",$Stack(-1),! If $Incr(err)
	; Don't compare the last stack location as it contains the current location which is obviously changing.
	For i=1:1:SVstkdpth-1 If $Stack(i,"PLACE")'=SVstk(i) Write "FAIL: Stack level 1 expected/actual: ",SVstk(i),"/",$Stack(i,"PLACE"),! If $Incr(err)

	Write "C9J04003108 ",$Select((0=err):"PASS",1:"FAIL"),!
	Set $ECode=""
	Quit

zintr	; Counted frame due to DO in $ZInterrupt
	; Do something to modify $Stack/$ECode so we can verify they are restored when we come back.
	Set j=maxloop+10	; Cause wait loop to abort when current sleep is over when wait loop restarts.
	Set $ECode=""		; Clear interrupt state to verify it is restored when return from this interrupt
	Quit
