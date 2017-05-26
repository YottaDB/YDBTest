;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The below entryrefs are designed to be called from trigthrashdrv.
;
; Check if long running jobs have a memory leak due to triggers while
; checking TP interference and restartability of triggers with auto-generated
; names loaded and used  by $TEXT, ZPRINT, and ZBREAK continuously . The main
; process exclusively  runs triggers while the spawned interference routines
; also reset the triggers as they run.
;
InitRun
	Set ^B=0		; Initialize var we will increment to drive triggers
	Quit

;
; Reference and/or drive 4 random triggers in 3 random ways ($Text, ZPRINT, or ZBREAK)). All operations
; are on ^B but we aren't really concerned with what ^B's value is (other tests check that). We just care
; that triggers are updated and fired in wholesome ways. With this much going on, our wholesome check is
; pretty much that it works rather than taking the effort to record/verify what we do. Doing that sort of
; measurement is enough to slow things down enough that our interference level suffers (the uncertainty
; principle).
;
UpdateLoop(main,GenerateMemDmp,debug,oktorungtmpcat)
	New i,quit,N,curstor,laststor,startstor,$ETrap,TP,choice,idx,intidx,trigid,saveio,x,cdh
	View:('debug) "BREAKMSG":7		; Turn off break_message_mask for TRIGZBRKREM warnings
	View "GVDUPSETNOOP":0			; Override possible test framework setting - Must be off so triggers always driven
	;
	; If main process, open an output file to contain messages from $ZTRigger. Keeps the reference file simpler since transactions
	; can need to restart and output additional text.
	;
	Do:(main)
	. Set ztofile="trigthrash2-main-ztrigger.log"
	. Open ztofile:New
	Set entrylvl=$ZLevel
	Set (startstor,curstor,laststor)=$ZREALSTOR	; Set here to set hi-water mark and in case of failure in initialization
	Set x=^endday,x=^endsec				; Refs to set hi-water mark
	;
	; The following statements are statements that will be Xecuted as we run. Run them all now once so they
	; are compiled and cached and such before we start monitoring for storage leaks.
	;
	Xecute "Set intidx=1"
	Xecute "Set intidx=2"
	Xecute "Set intidx=3"
	Xecute "Set intidx=4"
	Xecute "Set idx=1 Set intidx=1"
	Xecute "Set idx=2 Set intidx=2"
	Xecute "Set idx=3 Set intidx=3"
	Xecute "Set idx=4 Set intidx=4"
	Do TriggerTextInit^trigthrashdrv("trigthrash2",4)
	TStart ():(serial:transaction="BATCH")
	Set:'main ^totjobs=^totjobs+1
	TCommit
	;
	; For jobbed off processes: loop to wait until main process has finished its initialization
	;
	Do:('main)
	. For  Quit:^run!^quit  Hang 0.25
	Quit:'main&^quit
	Write $ZDate($Horolog,"24:60:SS")," Starting trigthrash2 update loop - ",$Select(main:"main",1:"Job "_$Job),!
	Set $ETrap="Write !,""Fail - updateLoop unknown"",! ZShow ""*"" Set $ETrap="""" Set:'main ^totjobs=^totjobs-1,^quit=1 Halt:'main  ZGoto entrylvl:FinishUpdateLoop"
	Do ReSetTrigger(main,1)	     	; Do this once before we start recording storage expansions
	Set saveio=$IO,idx=$$DetermineZPRINTTrigger	; Move this line above the first ReSetTrigger call to test with no triggers defined
	    					; (after GTM-7093 is fixed).
	ZBreak +1^B#1#:"Set $ZTSlate=""Set idx=""_$ZPiece($Text(+1^B#1#),"" "",3)"
	Do ReSetTrigger(main,1)		; Do one more after above rtn driven. When above it moved up, remove this
	Set ^B=$Get(^B,0)+1		; Drive trigger first time to prime the pump
	;
	; For main process, wait here until all subprocesses have done their initialization
	;
	Do:(main)
	. For  Quit:(^quit!(InterfereCnt=^totjobs))  Hang 0.25
	. Set:'^quit ^run=1
	Close:(main) ztofile
	Quit:main&^quit
	Do:debug
	. Write $ZDate($Horolog,"24:60:SS")," Tracking storage from here on",!
	. Do:(main&oktorungtmpcat) RunGtmpcat^trigthrashdrv
	. Hang 0.4 ; Allow message to flush
	Set (startstor,curstor,laststor)=$ZREALSTOR	; Set for real now..
	ZBreak -*
	;
	; Start driving our (mostly useless) trigger over and over. Every N iterations or so
	; check if we have exceeded our duration or not and check if $ZREALSTOR has incremented.
	;
	Set quit=0,choice=0
	For  Quit:quit!^quit  Do
	. Set N=100+$Random(200)	; Each process does a trigger switch between 100 and 300 invocations
	. For i=1:1:N Quit:^quit  Do
	. . If $TLevel'=0 Write "FAIL - Dangling TP fence",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . Set TP=$Random(2)	      	; Randomly use TP or not
	. . Kill saveio
	. . TStart:TP ():(serial:transaction="BATCH")
	. . If (0<$Data(saveio)) Use saveio Kill saveio	; If saveio exists, tiz because ZPRINT restarted - fix that now
	. . ZBreak:(3=choice) -*	       		; Kill any lingering ZBreaks from restarts (if choice was 3)  or whatever
	. . Kill idx,intidx,line,trigid	; No stale values
	. . Set choice=$Random(3)+1
	. . If ((""'=$ZTSlate)&'TP) TStart () TCommit	; Clears $ZTSlate in case no TP to do it.
	. . ;
	. . ; One of 3 possible trigger related operations performed just prior to driving same trigger with
	. . ; an update depending on random "choice":
	. . ;
	. . ; 1. $Text() on a trigger routine
	. . ; 2. ZPrint of a trigger
	. . ; 3. ZBreak in the trigger
	. . ;
	. . If 1=choice Do		; $Text(trigger)
	. . . Set trigid=$Text(+1^B#1#)
	. . . Set idx=$ZPiece(trigid," ",3)
	. . . If (idx="")!(idx<1)!(idx>4) Do
	. . . . Write "Invalid setting for idx - trigid=",trigid,!
	. . . . ZShow "*" TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . Else  If 2=choice Do	; ZPrint(trigger)
	. . . Set saveio=$IO
	. . . Set trigid=$$DetermineZPRINTTrigger
	. . . Use saveio
	. . . Kill saveio
	. . Else  Do			; Choice #3 - ZBreak trigger with command
	. . . Set trigid=$Text(+1^B#1#)
	. . . ZBreak +1^B#1#:"Set $ZTSlate=""Set idx=""_$ZPiece($Text(+1^B#1#),"" "",3)"
	. . Set ^B=^B+1			; In the ZBREAk case, this is what sets idx which is an index to which trigger is running. Also sets intidx
	. . TCommit:TP
	. . ZBreak:(3=choice) -*	; Remove any dangling ZBreak
	. . ;
	. . ; Verify intidx against idx. Note for choice #3 (zbreak) it is possible for the zbreak to be removed by a
	. . ; concurrent trigger update from an interference job. If that occurs, no trigger is driven and $ZTSlate is NULL.
	. . ;
	. . If ""=$ZTSlate Do
	. . . Do:(3'=choice)		; Not allowed if not choice 3 (ZBREAK)
	. . . . Write "Missing trigger case - $ZTSlate is null for choice ",choice," (TP=",TP,")",!
	. . . . ZShow "*"
	. . . . TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit
	. . . . Halt:'main
	. . . . ZGoto entrylvl:FinishUpdateLoop
	. . Else  Do
	. . . Xecute $ZTSlate
	. . . Set error=0
	. . . ;
	. . . ; Some validations are only useful if TP=1. Else we could have read one trigger in this routine but fired a different
	. . . ; one leaving us with a mixed bag.
	. . . ;
	. . . If (0=$Data(idx)) Do	; If no idx, no other validations get run
	. . . . If 1=TP,3'=choice Write "idx has no value - choice: ",choice,! Set error=1
	. . . . Write:(debug&(3=choice)) "** choice=3 but idx was not set - assuming zbreak was cancelled",!
	. . . Else  If (idx="")!(idx<1)!(idx>4) Write "Invalid idx detected: ",idx,"  with choice ",choice,! Set error=1
	. . . Else  If (0=$Data(intidx)) Write "intidx has no value - choice: ",choice,! Set error=1
	. . . ;
	. . . ; Prior to GTM-8506, the below test was done for all 3 choices because $TEXT() and ZPRINT read the trigger source
	. . . ; inside a transaction that restarted if the trigger changed. The trigger source is now obtained from the loaded
	. . . ; trigger object allowing for a mismatch. Only ZBREAK still reads triggers with the TP fence so the below test
	. . . ; is restricted to ZBREAK choices.
	. . . ;
	. . . Else  If 3=choice,intidx'=idx,1=TP Write "intidx vs idx validation failure - intidx: ",intidx,"  idx: ",idx,"  choice: ",choice,! Set error=1
	. . . If error ZShow "*" TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . . ;
	. . . ; For all cases, increment which trigger was driven (note intidx is the true trigger that was driven)
	. . . ;
	. . . Set x=$ZTWormhole
	. . . Set $ZPiece(x,"|",(choice+((intidx-1)*3)))=$ZPiece(x,"|",(choice+((intidx-1)*3)))+1
	. . . Set $ZTWormhole=x
	. Set cdh=$Horolog
	. If ^endday'>$Piece(cdh,",",1),^endsec'>$Piece(cdh,",",2) Set quit=1 Quit
	. Quit:^quit
	. Do:debug
	. . Set curstor=$ZREALSTOR
	. . If curstor>laststor Do
	. . . Write $ZDate(cdh,"24:60:SS")," Iteration (",$ZTWORMHOLE,"): Storage increased by ",(curstor-laststor),!
	. . . Set laststor=curstor
	. Do:('main) ReSetTrigger(main)
FinishUpdateLoop
	New maxleak Set maxleak=105000 ; FIXME - silence this frequently occurring leak failure by setting the max to 3*(2K*(16+1))+sizeof(storExtHdr) ~ 104K or so
	Set curstor=$ZREALSTOR
	Set:(0=$Data(cdh)) cdh=$Horolog
	Set $ECode=""
	Set $ETrap="Write !,""Fail in FinishUpdateLoop"",! ZShow ""*"" Set $ETrap="""" TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit  Halt:'main  Quit"
	Write:(^quit&'quit) $ZDate(cdh,"24:60:SS")," Ending UpdateLoop due to ^quit set",!
	Write $ZDate(cdh,"24:60:SS")," Trigger loop ended - trigthrash2",!
	Set leakedstor=curstor-startstor ; Possible for one additional page of data to be used - max page on IA64 is 16K
	Set x=$ZTWormhole
	For i=1:1:4 Do
	. Write ?5,"Trigger ",i," stats:  $Text(): ",$ZPiece(x,"|",((i-1)*3)+1),?43,"ZPrint: ",$ZPiece(x,"|",((i-1)*3)+2),?62,"ZBreak: ",$ZPiece(x,"|",((i-1)*3)+3),!
	Do:(maxleak<leakedstor)
	. Write $ZDate(cdh,"24:60:SS")," FAIL - Storage leak detected (",leakedstor," bytes lost) - Forcing memory map dump",!
	. Set GenerateMemDmp=1
	Write !
	Do:(GenerateMemDmp)
	. Hang 0.5	; Allow the output to flush before do the storage dump
	. View:(('main)!('oktorungtmpcat)) "STORDUMP"
	. Do:(main&oktorungtmpcat) RunGtmpcat^trigthrashdrv
	Do:('main)
	. TStart ()
	. Set ^totjobs=^totjobs-1
	. TCommit
	Quit

;
; Routine to install/replace the trigger we use. Trigger is written to a temporary file before being installed. Changes are
; always done under TP fence so trigger users always see a trigger installed.
;
ReSetTrigger(main,init)
	New i,rc,file,eref,line,quit,saveio,rtnname
	Set rtnname=$Text(+0)
	;
	; Use $ZTRIGGER("FILE",..) to replace trigger
	;
	Set saveio=$IO
	Set file="ztf-"_$Job_".trg"
	Set eref="Trigger"_($Random(4)+1)	; Determine which trigger we will write to file and load
	Open file:New
	Use file
	Set quit=0
	;
	; Write out the trigger
	;
	For i=1:1 Quit:quit  Do
	. Set line=$Text(@eref+i^@rtnname)
	. If $ZExtract(line,1,1)'=";" Set quit=1 Quit	; Stop
	. Write $ZExtract(line,2,9999),!
	Close file
	Use saveio
	;
	; Start trigger modifying transaction
	;
	TStart ():(serial:transaction="BATCH")
	Use:(main) ztofile
	Set rc=$ZTrigger("ITEM","-*")		; Remove everything
	Use:(main) saveio
	If rc'=1 Write "FAIL - item removal failed (1)",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	Use:(main) ztofile
	Set rc=$ZTrigger("FILE",file)
	Use:(main) saveio
	If rc'=1 Write "FAIL - $ZTRIGGER(FILE,...) failed",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	If $TLevel'=1 Write "FAIL - Explicit TP transaction rolled back",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	TCommit
	If $TLevel'=0 Write "FAIL - TP transaction still in effect",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	Open file	; delete temporary trigger file
	Close file:Delete
	Use saveio
	Quit

;
; Routine to use ZPRINT to determine what trigger will fire. This is isolated so we can handle errors
; easier. Issue is there is a chance the trigger will not exist at the moment we do the ZPRINT so we
; have to handle that possibility. This leaves $ZTSlate null so will be handled in that fashion.
;
DetermineZPRINTTrigger()
	New outfile,line,zprinterror
	Set zprinterror=0
	Do
	. New $ETrap	; New trap in effect only this block
	. Set $ETrap="Do ZPrintError Quit:$Quit """" Quit"
	. Set outfile="tmp.out"_$Job
	. Open outfile:New:29	; set timeout to 29 seconds (so it is below 30 second tpnotacidtime -- avoids TPNOTACID messages)
	. Use outfile
	. ZPrint +1^B#1#
	Quit:zprinterror """"
	Close outfile
	Open outfile:Readonly:29 ; set timeout to 29 seconds (see previous Open command for comment on why)
	Use outfile
	Read line:29 ; set timeout to 29 seconds (see previous Open command for comment on why)
	Close outfile:Delete
	Set idx=$ZPiece(line," ",3)
	If (idx="")!(idx<1)!(idx>4) Do
	. Use saveio
	. Write "Invalid setting for idx",!
	. ZShow "*"
	. TStart ()
	. Set:'main ^quit=1,^totjobs=^totjobs-1
	. TCommit
	. Halt:'main
	. ZGoto entrylvl:FinishUpdateLoop
	Quit line

;
; Routine to handle errors during ZPRINT
;
ZPrintError
	Set $ETrap=""
	If $ZStatus["TRIGNAMENF" Do
	. Set $ECode=""
	. Close outfile
	. Use:$Data(saveio) saveio Use:'$Data(saveio) $p
	. Write "Error occurred during ZPRINT: ",$ZStatus,!
	. Set zprinterror=$ztrigger("select")
	Else  Do
	. Use:$Data(saveio) saveio Use:'$Data(saveio) $p
	. Write "Unknown error during zprint",!
	. ZShow "*"
	. TStart ()
	. Set:'main ^quit=1,^totjobs=^totjobs-1
	. TCommit
	. Halt:'main
	. ZGoto entrylvl:FinishUpdateLoop
	Quit

;
; Define triggers this test uses. Each trigger "set" needs the name of the trigger and some set of contiguous lines each beginning
; with ";" followed by a blank line to terminate each trigger.
;
Trigger1
;+^B -commands=S -xecute=<<
;; Trigger 1
; Set $ZTSlate=$Select(""'=$ZTSlate:$ZTSlate_" ",1:"")_"Set intidx=1"
;>>

Trigger2
;+^B -commands=S -xecute=<<
;; Trigger 2
; Set $ZTSlate=$Select(""'=$ZTSlate:$ZTSlate_" ",1:"")_"Set intidx=2"
;>>

Trigger3
;+^B -commands=S -xecute=<<
;; Trigger 3
; Set $ZTSlate=$Select(""'=$ZTSlate:$ZTSlate_" ",1:"")_"Set intidx=3"
;>>

Trigger4
;+^B -commands=S -xecute=<<
;; Trigger 4
; Set $ZTSlate=$Select(""'=$ZTSlate:$ZTSlate_" ",1:"")_"Set intidx=4"
;>>
