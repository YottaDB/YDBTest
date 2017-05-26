; Test C002848 - interruptability of HANG to make sure it doesn't restart the timer
;
	; Obtain lock that gates our interrupt job so we control when it starts interrupting.
	;
	; Without the fix for C9H04-002848, this test hangs on UNIX and
	; ACCVIOs on VMS
	Set v2=$E($TR($P($ZV," ",2),".-V"),1,2)		; get 2 digits after V
	If v2<55 Write !,"c002848 test requires at least V5.5",! Quit
	Set (^intjobready,^intcnt,^quit)=0
	Lock +^intrgate
	;
	; Initialization
	;
	Set hadintr=0
	If $Get(^waitfor,0)=0 Set ^waitfor=20
	Set $ZInterrupt="Hang .5 Do checkintrpt^c002848"
	;
	; Setup jobs to create
	;
	Set jobindex=0	; job index for the main process
	Set jmaxwait=0	; No waiting for jobs to finish just yet
	Set jnoerrchk=1 ; Don't include interference jobs output in the error check
	Set ^mainpid=$Job
	Write $ZDate($Horolog,"24:60:SS")," Starting interference job",!
	Do job^job("intrptjob^c002848",1,"""""")
	;
	; Wait for interrupter job to establish itself
	;
	Set starttime=$H
	For  Quit:(^intjobready!($$^difftime($H,starttime)>(15*60)))  Hang 0.25
	If '^intjobready Do
	. Write "FAIL: Interrupter job not started - giving up",!
	. Quit
	Write $ZDate($Horolog,"24:60:SS")," Releasing interference job - running until interrupt HANG",!
	;
	; Release interrupter job and loop until we get an interrupt in a hang
	;
	Set loopcnt=0
	Lock -^intrgate
	For  Quit:^quit  Do
	. Kill ^hangint("after")
	. Set (^hangint("before"),^hangint(loopcnt,"before"))=$h
	. Set (^hangint("before","intcnt"),^hangint(loopcnt,"before","intcnt"))=^intcnt
	. Hang ^waitfor
	. Set:(hadintr) ^quit=1
	. Set (^hangint("after"),^hangint(loopcnt,"after"))=$h
	. Set (^hangint("after","intcnt"),^hangint(loopcnt,"after","intcnt"))=^intcnt
	. Set ^hangint(loopcnt,"elapsed")=$$^difftime(^hangint(loopcnt,"after"),^hangint(loopcnt,"before"))
	. If ^hangint(loopcnt,"elapsed")>(^waitfor+1) Set ^quit=1,^hangint("error")="too long"
	. If ^hangint(loopcnt,"elapsed")<(^waitfor-1) Set ^quit=1,^hangint("error")="too short"
	. Set loopcnt=loopcnt+1
	;
	If $Data(^hangint("error")) Do
	. Write $ZDate($Horolog,"24:60:SS")," Error - Hang took ",^hangint("error"),": "
	. Write ^hangint(loopcnt-1,"elapsed")," seconds",!
	If hadintr&'$Data(^hangint("error")) Do
	. Write $ZDate($Horolog,"24:60:SS")," Successful return from interrupted HANG after ",loopcnt," iterations - PASS",!
	Write:'hadintr $ZDate($Horolog,"24:60:SS")," Test ended prematurely due to error - FAIL",!
	Do wait^job    ; interrupter job has been signalled to terminate - wait for it so we are last one out
	Quit

;
; $ZInterrupt handler - check if we got an interrupt during a hang or not.
;
checkintrpt
	If $Data(^hangint("before"))=0 Quit	; too soon
	Set ^zint(^intcnt)=$H
	If $Data(^hangint("after"))=0 Set (^quit,hadintr)=1
	Quit

;
; Interrupter job
;
intrptjob
	New mainpid
	Set unix=$ZVersion'["VMS"
	If unix=0 Set minsnooze=10000,maxsnooze=25000	;from tsockzintr.m with changes
	Set $ETrap="Set $ETrap="""" Set ^quit=1 Write $ZStatus,! ZShow ""*"" Halt"
	Set mainpid=^mainpid
	Set ^intjobready=1,^intcnt=0
	Write $ZDate($Horolog,"24:60:SS")," Interference job starting up",!
	Lock +^intrgate:5		; Wait at the gate until the main process releases us
	If '$Test Write $ZDate($Horolog,"24:60:SS")," Gating lock timed out - failing test",! Set ^quit=1 Quit
	For  Quit:^quit  Do
	. If unix Do
	. . ZSystem "$gtm_dist/mupip intrpt "_mainpid
	. Else  Do
	. . Hang ($Random(maxsnooze-minsnooze)+minsnooze)/10000	;avoid overwhelming OpenVMS signal handler
	. . If $ZSigproc(mainpid,16) Set ^quit=1 Quit
	. Set ^intcnt=^intcnt+1
	. Set:(0'=$ZSigproc(mainpid,0)) ^quit=1	; If target process goes away, so do we
	Write $ZDate($Horolog,"24:60:SS")," Interference job shutting down after sending ",^intcnt," interrupts",!
	Quit
