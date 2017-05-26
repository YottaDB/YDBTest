; Test C9J06-003137 - interruptability of ZSHOW to make sure it resumes where it left off..
;
	New c,d,e,f,g,h,i,j	; Some new vars we don't touch so references to vars in zshowintr cause issues.
	;
	; Obtain lock that gates our interrupt job so we control when it starts interrupting.
	;
	Set ^intjobready=0,^quit=0
	Lock +^intrgate
	;
	; Initialization
	;
	Set maxvars=2000
	For i=1:1:maxvars Set a(i)=i	; A cute little array to give zshow something significant to do
	Set hadintr=0
	Set $ZInterrupt="Do checkintrpt^zshowintr"
	;
	; Setup jobs to create
	;
	Set jobindex=0	; job index for the main process
	Set jmaxwait=0	; No waiting for jobs to finish just yet
	Set jnoerrchk=1 ; Don't include interference jobs output in the error check
	Set ^mainpid=$Job
	Write $ZDate($Horolog,"24:60:SS")," Starting interference job",!
	Do job^job("intrptjob^zshowintr",1,"""""")
	;
	; Wait for interrupter job to establish itself
	;
	For  Quit:^intjobready  Hang 0.25
	Write $ZDate($Horolog,"24:60:SS")," Releasing interference job - running until interrupt ZSHOW",!
	;
	; Release interrupter job and loop until we get an interrupt in a zshow
	;
	Set loopcnt=0
	Lock -^intrgate
	For  Quit:^quit  Do
	. Kill zsrslt
	. Do ^zshowintr2	; Setup restartpc in a remote module
	. ZShow "V":zsrslt
	. Set:(hadintr) ^quit=1
	. Set loopcnt=loopcnt+1
	;
	Write:hadintr $ZDate($Horolog,"24:60:SS")," Successful return from interrupted ZSHOW after ",loopcnt," iterations - PASS",!
	Write:'hadintr $ZDate($Horolog,"24:60:SS")," Test ended prematurely due to error - FAIL",!
	Do wait^job    ; interrupter job has been signalled to terminate - wait for it so we are last one out
	Quit

;
; $ZInterrupt handler - check if we got an interrupt during a zshow or not.
;
checkintrpt
	New lines
	Set lines=$Order(zsrslt("V",99999999),-1)
	Set:(maxvars>lines) hadintr=1	; If insufficient lines in output, ZSHOW was interrupted
	Quit

;
; Interrupter job
;
intrptjob
	New intcnt,mainpid
	Set $ETrap="Set $ETrap="""" Set ^quit=1 Write $ZStatus,! ZShow ""*"" Halt"
	Set mainpid=^mainpid
	Set ^intjobready=1,intcnt=0
	Write $ZDate($Horolog,"24:60:SS")," Interference job starting up"
	Lock +^intrgate:5		; Wait at the gate until the main process releases us
	If '$Test Write $ZDate($Horolog,"24:60:SS")," Gating lock timed out - failing test",! Set ^quit=1 Quit
	For  Quit:^quit  Do
	. ZSystem "$gtm_dist/mupip intrpt "_mainpid
	. Set intcnt=intcnt+1
	. Set:(0'=$ZSigproc(mainpid,0)) ^quit=1	; If target process goes away, so do we
	Write $ZDate($Horolog,"24:60:SS")," Interference job shutting down after sending ",intcnt," interrupts",!
	Quit
