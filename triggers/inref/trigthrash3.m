;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
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
; checking if a nested trigger for the same global can cause a restart that
; negatively affects the trigger already executing.
;
InitRun
	Kill ^antp		; Initialize by removing previous results (if any)
	Kill ^antptrig
	Quit

;
; Run nested triggers within the same global yet pause long enough between triggers so make it fairly common that the
; triggers for the global get replaced. If the nested trigger causes a reload, expect things to fail rather badly.
;
UpdateLoop(main,GenerateMemDmp,debug,oktorungtmpcat)
	New i,quit,N,curstor,laststor,startstor,$ETrap,TP,entrylvl,cdh
	View "GVDUPSETNOOP":0					; Override possible test framework setting - Must be off so triggers always driven
	;
	; If main process, open an output file to contain messages from $ZTRigger. Keeps the reference file simpler since transactions
	; can need to restart and output additional text.
	;
	Do:(main)
	. Set ztofile="trigthrash3-main-ztrigger.log"
	. Open ztofile:New
	;
	Set (startstor,curstor,laststor)=$ZREALSTOR		; Preset so exists in case of failure and help set hi-water mark
	Set x=^endday,x=^endsec					; Refs for storage hi-water mark (allocates memory)
	Do TriggerTextInit^trigthrashdrv("trigthrash3",2)	; More init so don't expand storage while monitoring for leaks
	Do ReSetTrigger(main)	  	  	   		; Do this once before we start recording storage expansions
	Set entrylvl=$ZLevel
	TStart ():(serial:transaction="BATCH")
	Set:'main ^totjobs=^totjobs+1
	TCommit
	Write $ZDate($Horolog,"24:60:SS")," Starting trigthrash3 update loop - ",$Select(main:"main",1:"Job "_$Job),!
	Set $ETrap="Write !,""Fail - updateLoop unknown"",! ZShow ""*"" Set $ETrap="""" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop"
	Do ReSetTrigger(main)	     			    	; Last trigger re-init before record storage hi-water mark
	Set ^antp(1,1)=1					; Drive trigger first time to prime the pump
	Close:(main) ztofile
	Do:debug
	. Write $ZDate($Horolog,"24:60:SS")," Tracking storage from here on",!
	. Do:(main&oktorungtmpcat) RunGtmpcat^trigthrashdrv
	. Hang 0.4 ; Allow message to flush
	Set (startstor,curstor,laststor)=$ZREALSTOR		; Set for real now..
	;
	; Start driving our (mostly useless) trigger over and over. Triggers nest 2 deep within the same global.
	;
	Set quit=0
	For  Quit:quit!^quit  Do
	. If $TLevel'=0 Write "FAIL - Dangling TP fence",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. Set TP=$Random(2)
	. TStart:TP ():(serial:transaction="BATCH")
	. Set ^antp(1,$Random(100000)*(jobindex+1))=$Random(1000000)
	. TCommit:TP
	. Set cdh=$Horolog
	. If ^endday'>$Piece(cdh,",",1),^endsec'>$Piece(cdh,",",2) Set quit=1 Quit
	. Quit:^quit
	. Do:debug
	. . Set curstor=$ZREALSTOR
	. . Do:(curstor>laststor)
	. . . Write $ZDate(cdh,"24:60:SS")," Storage increased by ",(curstor-laststor),!
	. . . Set laststor=curstor
	. Do:('main) ReSetTrigger(main)
FinishUpdateLoop
	New maxleak Set maxleak=34860 ; FIXME - silence this frequently occurring leak failure by setting the max to (2K*(16+1))+sizeof(storExtHdr) ~ 34K + 40 or so
	Set curstor=$ZREALSTOR
	Set:(0=$Data(cdh)) cdh=$Horolog
	Set $ECode=""
	Set $ETrap="Write !,""Fail in FinishUpdateLoop"",! ZShow ""*"" Set $ETrap="""" TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit  Halt:'main  Quit"
	Write:(^quit&'quit) $ZDate(cdh,"24:60:SS")," Ending UpdateLoop due to ^quit set",!
	Write $ZDate(cdh,"24:60:SS")," Trigger loop ended - trigthrash3",!
	Set leakedstor=curstor-startstor ; Possible for one additional page of data to be used - max page on IA64 is 16K
	Do:(maxleak<leakedstor)
	. Write $ZDate(cdh,"24:60:SS")," FAIL - Storage leak detected (",leakedstor," bytes lost) - Forcing memory map dump",!
	. Set GenerateMemDmp=1		; Give us a shot at debugging why it extended
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
; Routine to install/update the trigger we use - should only be called from UpdateLoop due to error handling return to
; that routine.
; Note we always use TP to remove/update the trigger in this thrasher flavor.
;
ReSetTrigger(main,init)
	New rc,eref,rtnname,nxttrig,saveio
	Set rtnname=$Text(+0)
	Set:(main) saveio=$IO
	;
	; Use $ZTRIGGER("ITEM",..) to replace trigger
	;
	TStart ():(serial:transaction="BATCH")
	Set nxttrig=('$Get(^antptrig,0)),^antptrig=nxttrig	; Always pick the "other" trigger than is currently loaded
	Set:(main) nxttrig=1					; If main, always choose trigger 2 (largest)
	Set eref="Trigger"_(nxttrig+1)				; Determine which trigger we will write to file and load
	Use:(main) ztofile
	Set rc=$ZTrigger("ITEM","-*")				; Remove everything
	Use:(main) saveio
	If rc'=1 Write "FAIL - item removal failed (1)",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	;
	Use:(main) ztofile
	Set rc=$ZTrigger("ITEM",$ZExtract($Text(@eref+1^@rtnname),2,9999))
	Use:(main) saveio
	If rc'=1 Write "FAIL - $ZTRIGGER(ITEM,...) failed",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	If $TLevel'=1 Write "FAIL - Explicit TP transaction rolled back",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	Use:(main) ztofile
	Set rc=$ZTrigger("ITEM",$ZExtract($Text(@eref+2^@rtnname),2,9999))
	Use:(main) saveio
	If rc'=1 Write "FAIL - $ZTRIGGER(ITEM,...) failed",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	If $TLevel'=1 Write "FAIL - Explicit TP transaction rolled back",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	TCommit
	If $TLevel'=0 Write "FAIL - TP transaction still in effect",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	Quit

;
; Define triggers this test uses. Each trigger "set" needs the name of the trigger and some set of contiguous lines each beginning
; with ";" followed by a blank line to terminate each trigger.
;

Trigger1
;+^antp(1,fillid=:) -commands=SET  -xecute="Set ^antp(2,fillid)=$ztval"
;+^antp(2,fillid=:) -commands=SET  -xecute="Hang 0.0100 Set ^antp(3,fillid)=$ztval"

Trigger2
;+^antp(1,fillid=:) -commands=SET  -xecute="Set ^antp(2,fillid)=$ztval_$Job"
;+^antp(2,fillid=:) -commands=SET  -xecute="Hang 0.0101 Set ^antp(3,fillid)=$ztval"
