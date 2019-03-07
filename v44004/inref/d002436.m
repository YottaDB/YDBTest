;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
d002436 ;
	; Purpose of this test is to make sure that if a job interrupt comes in while doing
	; various "long running" commands that the resume point is where it should be (restart
	; the command, not the last place status was actually saved by a previous long running
	; command). The long running commands tested are:
	;
	; MERGE		se 4/2004
	;

	Set mergemax=500
	Set neededin=10
	Set unix=$ZVersion'["VMS"
	Set $Ztrap="d ztrprtn^d002436"
	;
	; This $ZINTERRUPT handler only needs to increment a counter to say we were here.
	Set zi=0	 ; $ZINTERRPT count
	Set $ZInterrupt="Set zi=zi+1"

	Set ^done=0
	Set ^drvactive=0
	Set ^cnt=0

	; Initialize Merge array
	For i=1:1:mergemax Set ^A(i)=i

	; We have an external job to be our processus interruptus
	Lock +^interrupter
	Write "Spawning interrupter job",!
	If unix job @("intrdrv^d002436($j,unix):(output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	Else    job @("intrdrv^d002436($j,unix):(nodetached:startup=""startup.com"":output=""intrdrv.mjo"":error=""intrdrv.mje"")")
	Write "."
	For i=1:1 Quit:^drvactive=1  hang 1  ; Wait for intrdrv to start

	Write !,"Beginning MERGE test",!

	; Loop until we have had "neededin" interceptions that interrupted a MERGE or until the loop exhausts itself
	; (which will be considered a loop timeout and a failure to be investigated).

	Set err=0
	Set mi=0	 ; Merge intercept count
	Set quit=0
	Set starttime=$Horolog,maxwait=60,elapsedtime=0
	Lock -^interrupter
	For miloop=1:1 Quit:(mi'<neededin)!(quit)!(maxwait<elapsedtime)  Do
	. Kill A
	. Set excont=0	 ; Execution continuity indicator
	. Hang 0	 ; This sets a resume point in "restartpc". If we restart here, we will double increment excont
	. Set excont=excont+1
	. ; Again increment our "continuity indicator" and save the interrupt count. If the interrupt count changes during
	. ; the MERGE, then the merge fielded the interrupt since no linestart or linefetch would have triggered it.
	. Set excont=excont+1 Set savzicnt=zi Merge A=^A If savzicnt'=zi Set mi=mi+1
	. If excont>2 Do       ; make sure line did not restart back at linestart or back to hang and double increment excont
	. . Set err=err+1
	. . Set quit=1
	. . Write !,"**ERROR** Erroneous interrupt restart point caused improper re-execution of line"
	. Set elapsedtime=$$^difftime($horolog,starttime)

	Write !,"Exiting interrupt stage -- waiting for interrupter to shutdown",!

	Set ^done=1
	Lock +^interrupter
	Write "."		; to have at least one .

	Write !,"Shutdown complete",!

	Set message="The required loops to get "_zi_" interrupts during MERGE: "_miloop
	Do:mi=0  ; While the above loop will attempt 10 hits over 60s, relax the passing criteria to just 1 to avoid rare failures
	. Set err=err+1
	. Set message="Loop exhausted prior to reaching even 1 interrupt (mi="_mi_",neededin="_neededin_"). Number of interrupted merges:"_zi

	If err=0 Do
	. Write !,"Test Passed",!
	Else  Do
	. Write !,"Test Failed",!,message,!
	. Kill A	; Don't need this in any storage dumps
	. ZSHOW "*"
	Quit

intrdrv(pid,unix)
	Set $ZTRAP="S $ZT="""" s ^drvactive=0 ZSHOW ""*"" Halt"
	If unix Set x=$&ydbposix.signalval("SIGUSR1",.sigval),sigusr1=sigval
	Else  Set sigusr1=16,hangtime=.02 ; Restrict $ZSIGPROC to 50 interrupts/sec
	Set ^drvactive=1
	Lock +^interrupter ; wait until the parent lets go of the lock
	Write "Interrupt job beginning for process ",pid,!,$Horolog,!
	If unix Set cmd="$gtm_dist/mupip intr "_pid

	; Interrupt until we are requested to shutdown or we reach an outer limit of 1,000 interrupts
	; which probably means we were orphaned and are just chewing up cpu time.
	For x=1:1 Quit:(^done=1)  Do
	. Set ret=$ZSigproc(pid,sigusr1)
	. If ret Set ^done=1 Write "TEST-W-WARN: ZSIGPROC returned an error ",ret,! Quit
	. Set ^cnt=x
	. Set:unix hangtime=2/(100-$random(76)) ; On Unix, float $ZSIGPROC to between 12-50 interrupts/sec
	. Hang hangtime	 ;	Avoid spinning in a tight loop, otherwise GT.M may fall into "hole"
	;			in zinterrupt processing where the wrong handler handles the interrupt
	;			causing bizzare and unpleasant reactions.
	Set ^drvactive=0
	Write "Interrupt job ",pid," complete after delivering ",^cnt," interrupts",!,$Horolog,!
	Quit

	; Simplistic .. shut it all down..
ztrprtn Set $ZT=""
	Set ^done=1,^drvactive=0
	ZSHOW "*"
	Halt
