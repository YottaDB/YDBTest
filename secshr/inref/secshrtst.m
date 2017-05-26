;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test (most) basic functions of gtmsecshr. In the test, this is run once with $gtm_usesecshr
; turned on and once off so that, at least in a debug build, gtmsecshr is used even in deference to faster
; methods and again with the debug build, all those usages are logged in the operator log.
;

	Kill ^x,^running,^continue	; Init vars in R/W database - R/O db already loaded
	Set maxwait=240			; Max startup wait for 2ndary process (in half seconds)
	Set maxcritwait=30		; Max attempts waiting for crit hang
	Set jmaxwait=0			; Return immediately after jobbing
	Set jnoerrchk=1			; Simplify ref file - just a lock and return - nothing complex
	Set jnolock=1			; We handle the locks - keep it simple
	;
	; Record our gtmsecshr client pid
	;
	Set log="client_pid.txt"	; Write current client id to file
	Open log:(New:Write)
	Use log
	Write $Job,!
	Close log
	;
	; Write global array (opens database). The "rega" region is set to R/O access so this exercise opens
	; the database using gtmsecshr's DB_FLUSH_IPCS_INFO service both on open and close.
	;
	ZWrite ^a			; Open database
	;
	; Get a lock, then start a sub-job who will wait for the lock - demonstrates use of WAKE_MESSAGE gtmsecshr service.
	; **NOTE** Lock wakeup code is disabled until the next gtmsecshr phase so postpone this for now.
	;
	;Lock ^x				; Startup lock 2ndary will hang on till we release
	;Do ^job("lckjob^secshrtst",1,"""""")
	;Set results(0)=0
	;For i=1:1:maxwait Quit:(3'<results(0))  Hang 0.5 Do CommandToPipe("$gtm_dist/lke -wait",.results)
	;If (maxwait=i) Do
	;. Write "FAIL - Job did not start in the allotted time (",maxwait/2," seconds)",!
	;. ZHalt 1
	;Hang 0.5
	;Lock				; Release it for 2ndary process to grab
	;Do wait^job			; Wait for 2ndary process to finish
	;
	; Setup a situation that will force a CONTINUE_MESSAGE gtmsecshr service invocation.
	; Spawn a job which will invoke white-box-test WBTEST_HOLD_CRIT_TILL_LCKALERT which grabs crit and waits for
	; long enough to generate a MUTEXLCKALERT message which also drives mutex_salvage() which uses CONTINUE_PROCESS
	; gtmsecshr service.
	;
	Do ^job("critjob^secshrtst",1,"""""")
	For i=1:1:maxwait Quit:(0'=$Data(^running))  Hang 1
	;
	; We know the secondary job is running now. Do a series of updates - 1 per second. One of the updates
	; should find crit blocked. The 2ndary process sets ^complete when it has finished the crit-delay so
	; we can terminate the loop at that point.
	;
	For i=1:1:maxcritwait Set ^x(i)=1 Quit:(0'=$Data(^complete))  Hang 1
	If (maxcritwait=i) Write "FAIL - Job did not get MUTEXLCKALERT in allotted time (",maxcritwait," seconds)",!

	Do wait^job			; Wait for job to complete before exiting
	;
	; Because our $gtmroutines might contain autorelink-enabled directories, we need to get the respective shared
	; memory segments' IDs to remove them from the tests output. Those IDs are obtain from the RCTLDUMP.
	;
	if (""'=$ztrnlnm("gtm_test_autorelink_support")) ZSystem "$MUPIP rctldump >&! rctldump"_$Job_".log"
	Quit

;
; Job'd off process runs this simpleton which, if we are running with gtm_usesecshr, causes a gtmsecshr
; lock wakeup to be recorded by the parent process.
;
lckjob
	Write $ZDate($Horolog,"24:60:SS")_" Starting lock wait (pid ",$Job,")",!
	Lock ^x				; Wait till released
	Write $ZDate($Horolog,"24:60:SS")_" Lock wait complete",!
	Quit

;
; Job'd off process runs simple process which, if we are running with gtm_usesecshr, causes a gtmsecshr
; process-continue to be recorded by the parent process.
;
critjob
	Write $ZDate($Horolog,"24:60:SS")_" Starting crit wait (pid ",$Job,")",!
	Set ^running=1			; Signal we are active and open DEFAULT region
	View "STORDUMP"			; Triggers whitebox code that grabs crit in DEFAULT and holds it while
	     				; parent tries to do an update to same region. Hope for MUTEXLCKALERT
	Write $ZDate($Horolog,"24:60:SS")_" Crit wait complete",!
	Set ^complete=1			; Signal parent we have completed
	Quit

;
; Routine to execute a command in a pipe and return the executed lines in an array
;
CommandToPipe(cmd,results)
	New pipecnt,pipe,saveIO
      	Kill results
       	Set pipe="CmdPipe"
       	Set saveIO=$IO
       	Open pipe:(Shell="/bin/sh":Command=cmd)::"PIPE"
       	Use pipe
       	Set pipecnt=1
       	For  Read results(pipecnt) Quit:$ZEOF  Set pipecnt=pipecnt+1
       	Close pipe
       	Set results(0)=pipecnt-1
       	Kill results(pipecnt)
       	Use saveIO
       	Quit
