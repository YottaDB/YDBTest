; The below entryrefs are designed to be called from trigthrashdrv.
;
; Check if long running jobs have a memory leak due to triggers while
; checking TP interference and restartability of triggers driven by SET, 
; KILL, and ZTRIGGER while said triggers are being both used and updated
; continuously. The main process exclusively runs triggers while the 
; spawned interference routines also reset the triggers as they run.
;
InitRun
	Set ^B=0		; Initialize var we will increment to drive triggers
	Quit
	
;
; Drive various triggers in 3 random ways (KILL, SET, ZTRIGGER). Operations are all on ^B but we aren't
; really concerned with what ^B's value is (other tests check that). We just care that triggers are 
; updated and fired in wholesome ways. With this much going on, our wholesome check is pretty much that
; it works rather than taking the effort to record/verify what we do. Doing that sort of measurement is
; enough to slow things down enough that our interference level suffers (the uncertainty principle).
;
UpdateLoop(main,GenerateMemDmp,debug,oktorungtmpcat)
	New i,quit,N,curstor,laststor,startstor,$ETrap,TP,x,ops,leakedstor,entrylvl,op
	View "GVDUPSETNOOP":0	; Override possible test framework setting - Must be off so triggers always driven
	;
	; If main process, open an output file to contain messages from $ZTRigger. Keeps the reference file simpler since transactions
	; can need to restart and output additional text.
	;
	Do:(main)
	. Set ztofile="trigthrash1-main-ztrigger.log"
	. Open ztofile:New
	;
	; Initializations to use the memory we are going to use during the test to avoid false positives in mem leak detection.
	;
	Set ops(1)="Set ^B=$Get(^B,0)+1"
	Set ops(2)="ZTrigger ^B"
	Set ops(3)="Kill ^B"
	Set x=^endday,x=^endsec		; Refs to create accesses to these vars (allocates memory)
	Set (startstor,curstor,laststor)=$ZREALSTOR
	For i=1:1:3 Xecute ops(i)	; Drive these once before start recording storage expansions
	Do TriggerTextInit^trigthrashdrv("trigthrash1",4)
	Set entrylvl=$ZLevel
	TStart ():(serial:transaction="BATCH")
	Set:'main ^totjobs=^totjobs+1
	TCommit
	;
	; For jobbed off processes: loop to wait until main process has finished its initialization
	;
	Do:('main)
	. For  Quit:^run!^quit  Hang 0.25
	Quit:'main&^quit
	Write $ZDate($Horolog,"24:60:SS")," Starting update trigthrash1 loop - ",$Select(main:"main",1:"Job "_$Job),!
	Set $ETrap="Write !,""Fail - updateLoop unknown"",! ZShow ""*"" Set $ETrap="""" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop"
	Do ReSetTrigger(main,1)		; Set initial trigger, contribute to storage hi-water mark
	Set ^B=$Get(^B,0)+1		; Drive trigger first time to prime the pump
	;
	; For main process, wait here until all subprocesses have done their initialization
	;
	Do:(main)
	. For  Quit:(^quit!(InterfereCnt=^totjobs))  Hang 0.25
	. Set:'^quit ^run=1
	Quit:main&^quit
	Do:(main)
	. Do ReSetTrigger(main,1)		; Reset initial trigger, contribute to storage hi-water mark
	. Close ztofile
	Do:(debug)
	. Do:(main&oktorungtmpcat) RunGtmpcat^trigthrashdrv
	. Write $ZDate($Horolog,"24:60:SS")," Tracking storage from here on",!
	. Hang 0.5 ; Allow message to flush
	Set (startstor,curstor,laststor)=$ZREALSTOR
	;
	; Start driving our (mostly useless) trigger over and over. Every N iterations or so
	; check if we have exceeded our duration or not and check if $ZREALSTOR has incremented.
	; 
	Set quit=0
	For  Quit:quit!^quit  Do
	. Set N=100+$Random(200)
	. For i=1:1:N Quit:^quit  Do
	. . Kill cdh
	. . If $TLevel'=0 Write "FAIL - Dangling TP fence",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . Set TP=$Random(2)
	. . TStart:TP ():(serial:transaction="BATCH")
	. . Set op=$Random(3)+1
	. . Xecute ops(op)
	. . TCommit:TP
	. Set cdh=$Horolog
	. If ^endday'>$Piece(cdh,",",1),^endsec'>$Piece(cdh,",",2) Set quit=1 Quit
	. Quit:^quit
	. ;
	. ; Set debug to TRUE to see incremental changes in $ZREALSTOR
	. ;
	. Do:debug
	. . Set curstor=$ZREALSTOR
	. . If curstor>laststor Do
	. . . Write $ZDate(cdh,"24:60:SS")," Iteration (",$ZTWORMHOLE,"): Storage increased by ",(curstor-laststor),!
	. . . Hang 0.5			     ; Allow message to flush before proceeding
	. . . Set laststor=curstor
	. Do:('main) ReSetTrigger(main,0)
FinishUpdateLoop
	Set:(0=$Data(cdh)) cdh=$Horolog
	Set curstor=$ZREALSTOR
	Set $ECode=""
	Set $ETrap="Write !,""Fail in FinishUpdateLoop"",! ZShow ""*"" Set $ETrap="""" TStart () Set:'main ^quit=1,^totjobs=^totjobs-1 TCommit  Halt:'main  Quit"
	Write:(^quit&'quit) $ZDate(cdh,"24:60:SS")," Ending UpdateLoop due to ^quit set",!
	Write $ZDate(cdh,"24:60:SS")," Trigger loop ended - trigthrash1",!
	Set leakedstor=curstor-startstor ; Possible for one additional page of data to be used - max page on IA64 is 16K
	Set x=$ZTWormhole
	For i=1:1:4 Do
	. Write ?10,"Trigger ",i," stats:  Executions: ",$ZPiece(x,",",i),?50,"Restarts: ",$ZPiece(x,",",i+4),!
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
; Routine to (re)install the trigger we use. Trigger changes always happen under a TP fence so trigger users always have
; a trigger to drive (affects verification).
;
ReSetTrigger(main,init)
	New i,rc,file,eref,line,quit,ztormt,rtnname,saveio
	Set rtnname=$Text(+0)
	Set:(main) saveio=$IO
	If (main!init!$Random(2)) Do	; Don't do trigger 2 or 4 for main or if initializing to keep reference file uncomplicated
	. ;
	. ; Running either trigger 1 or 3 using $ZTRIGGER("FILE",..). Note these are the larger triggers so we want the main
	. ; process to run one of them first when it "primes the pump". These larger triggers need more storage so we want
	. ; the storage hi-water marker set appropriately so we don't incorrectly detect a "leak" later.
	. ;
	. Set ztormt=$Select(init:1,1:$Random(2))		; Use $ZTRIGGER (1) or MUPIP TRIGGER (0) to do the update?
	. Set file="ztf-"_$Job_".trg"
	. Set eref=$Select('init&$Random(2):"Trigger1",1:"Trigger3")	; Determine which trigger we will write to file and load
	. Open file:New
	. Use file
	. Write:('ztormt) "-*",!	; When using mupip trigger, put delete all in file so happens atomically
	. Set quit=0
	. For i=1:1 Quit:quit  Do
	. . Set line=$Text(@eref+i^@rtnname)
	. . If $ZExtract(line,1,1)'=";" Set quit=1 Quit	; Stop 
	. . Write $ZExtract(line,2,9999),!
	. Close file
	. If ztormt Do
	. . TStart ():(serial:transaction="BATCH")
	. . Use:(main) ztofile
	. . Set rc=$ZTrigger("ITEM","-*")		; Remove everything
	. . Use:(main) saveio
	. . If rc'=1 Write "FAIL - item removal failed (1)",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . Use:(main) ztofile
	. . Set rc=$ZTrigger("FILE",file)
	. . Use:(main) saveio
	. . If rc'=1 Write "FAIL - $ZTRIGGER(FILE,...) failed",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . If $TLevel'=1 Write "FAIL - Explicit TP transaction rolled back",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. . TCommit
	. . If $TLevel'=0 Write "FAIL - TP transaction still in effect",! ZShow "*" TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  Halt:'main  ZGoto entrylvl:FinishUpdateLoop
	. Else  Do
	. . ZSystem "$gtm_dist/mupip trigger -noprompt -trig="_file
	. . Do:(0'=$ZSystem)
	. . . Write "MUPIP TRIGGER -trig=",file," -- failed rc=",$ZSystem,!
	. . . TStart () Set:'main ^totjobs=^totjobs-1,^quit=1 TCommit  
	. . . Halt:'main  
	. . . ZGoto entrylvl:FinishUpdateLoop
	. Open file	; delete temporary trigger file
	. Close file:Delete
	. Use $P
	Else  Do
	. ;
	. ; Running either trigger 2 or 4 using $ZTRIGGER("ITEM",..) - never here in main so no need to do USE.
	. ;
	. Set eref=$Select($Random(2):"Trigger2",1:"Trigger4")	; Determine which trigger we will write to file and load
	. TStart ():(serial:transaction="BATCH")
	. Set rc=$ZTrigger("ITEM","-*")		; Remove everything
	. If rc'=1 Write "FAIL - item removal failed (2)",! ZShow "*" TStart () Set ^totjobs=^totjobs-1,^quit=1 TCommit  Halt
	. Set rc=$ZTrigger("ITEM",$ZExtract($Text(@eref+1^@rtnname),2,9999))
	. If rc'=1 Write "FAIL - $ZTRIGGER(ITEM,...) failed",! ZShow "*" TStart () Set ^totjobs=^totjobs-1,^quit=1 TCommit  Halt
	. If $TLevel'=1 Write "FAIL - Explicit TP transaction rolled back",! ZShow "*" TStart () Set ^totjobs=^totjobs-1,^quit=1 TCommit  Halt
	. TCommit
	. If $TLevel'=0 Write "FAIL - TP transaction still in effect",! ZShow "*" TStart () Set ^totjobs=^totjobs-1,^quit=1 TCommit  Halt
	Quit

;
; Triggers used by this routine
;
Trigger1
;+^B -commands=S,ZTR,K -xecute=<<
; Set whpc=1
; Set x=$ZTWormhole
; Set $ZPiece(x,",",whpc)=$ZPiece(x,",",whpc)+1
; Set:($TRestart>0) $ZPiece(x,",",4+whpc)=$ZPiece(x,",",4+whpc)+1
; Set $ZTWormhole=x
; Set x="some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage1"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage1"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage2"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage3"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage4"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage5"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage6"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage7"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage8"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage9"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage10"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage11"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage12"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage13"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage14"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage15"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage16"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage17"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage18"
; Set x=x_"some really long constant that will take up some space. And we will repeat it over and over so this takes up some non-trivial storage19"
;>>

Trigger2
;+^B -commands=S,ZTR,K -xecute="Set whpc=2 Set x=$ZTWormhole Set $ZPiece(x,"","",whpc)=$ZPiece(x,"","",whpc)+1 Set:($TRestart>0) $ZPiece(x,"","",4+whpc)=$ZPiece(x,"","",4+whpc)+1 Set $ZTWormhole=x"

Trigger3
;+^B -commands=S,ZTR,K -xecute=<<
; Set whpc=3
; Set x=$ZTWormhole
; Set $ZPiece(x,",",whpc)=$ZPiece(x,",",whpc)+1
; Set:($TRestart>0) $ZPiece(x,",",4+whpc)=$ZPiece(x,",",4+whpc)+1
; Set $ZTWormhole=x
; Set x="another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage20"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage21"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage22"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage23"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage24"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage25"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage26"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage27"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage28"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage29"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage30"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage31"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage32"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage33"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage34"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage35"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage36"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage37"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage38"
; Set x=x_"another really long constant that will take up some more space. And we will repeat it over and over so this takes up some non-trivial storage39"
;>>

Trigger4
;+^B -commands=S,ZTR,K -xecute="Set whpc=4 Set x=$ZTWormhole Set $ZPiece(x,"","",whpc)=$ZPiece(x,"","",whpc)+1 Set:($TRestart>0) $ZPiece(x,"","",4+whpc)=$ZPiece(x,"","",4+whpc)+1 Set $ZTWormhole=x"

