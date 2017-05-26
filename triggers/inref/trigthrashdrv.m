;
; This is a common driver for various trigthrash* tests. See the descriptions of those routines
; to know what they are testing. In general, the test runs for a specific period of time while
; spawning "interference jobs" that modify the running trigger(s) stressing trigger concurrency
; operations in various ways.
;
; Parameters are:
;
;   - DriveRtn       - routine name of test. Invoked from both main and from the interference rtns.
;   - TestDuration   - Duration of test in minutes.
;   - InterfereCnt   - Count of interference jobs.
;   - GenerateMemDmp - At the conclusion of the process (both main and interference jobs), create
;     		       a memory allocation dump with VIEW "STORDUMP".
;   - Debug          - Enables some extra checking and test debugging information.
;
Driver(DriveRtn,TestDuration,InterfereCnt,GenerateMemDmp,Debug)
	View "GVDUPSETNOOP":0	; Override possible test framework setting - Must be off so triggers always driven
	Set $ETrap="Set $ETrap="""" Write ""FAIL - main unknown"",! ZShow ""*"" Set ^quit=1 Halt"
	Set entrylvl=$ZLevel
	;
	; If discover what we think is a leak, we'll want to run gtmpcat against the process if possible. 
	; Determine if that is possible or not now.
	;
	Set gtmpcatok("AIX RS6000")=1
	Set gtmpcatok("HP-UX IA64")=1
	Set gtmpcatok("HP-UX HP-PA")=1
	Set gtmpcatok("Linux IA64")=1
	Set gtmpcatok("Linux x86_64")=1
	Set gtmpcatok("Linux S390X")=1
	Set gtmpcatok("Linux x86")=1
	Set gtmpcatok("Solaris SPARC")=1
	Set gtmpcatok("OSF1 AXP")=0
	Set gtmpcatok("OS390 S390")=0
	Set platform=$Piece($ZVersion," ",3,4)
	If (0=$Data(gtmpcatok(platform))) Write "Running on unknown platform - add proper flag to trigthrashdrv.m",!
	Set oktorungtmpcat=$Get(gtmpcatok(platform),0)
	ZSystem:(oktorungtmpcat) "$cms_tools/gtmpcatfldbld.csh "_$Translate($Piece($ZVersion," ",2),".-","")_" >& gtmpcatfldbld-"_$ZDate($Horolog,"YEARMMDD-2460SS")_".log"
	;
	Set maxdh2=24*60*60	; Max value + 1 for compare to $Piece($Horolog,",",2)
	Set main=1
	Set ^startdh=$Horolog
	Set startday=$Piece(^startdh,",",1)
	Set startsec=$Piece(^startdh,",",2)
	Set ^endsec=startsec+(TestDuration*60)
	Set ^endday=startday
	If ^endsec'<maxdh2 Do
	. Set ^endsec=^endsec-maxdh2
	. Set ^endday=^endday+1
	Set rc=$ZTrigger("ITEM","-*")		; Remove everything so our initialization doesn't drive anything
	Set ^totjobs=0,^quit=0,^run=0
	Do InitRun^@DriveRtn			; test specific initializations
	Set $ZTWormhole=""
	;
	; Cause some routines we use to get linked in with $Text() so we don't load $Text later 
	; causing issues with our storage leak detection.
	;
	Set x=$Text(+1^job)
	Set x=$Text(+1^isprcalv)
	Set x=$Text(+1^@DriveRtn)
	;
	; Setup jobs to create
	;
	Set jobindex=0	; job index for the main process
	Set jmaxwait=0	; No waiting for jobs to finish just yet
	Set jnoerrchk=1 ; Don't include interference jobs output in the error check
	Do:(0<InterfereCnt)
	. Write $ZDate(^startdh,"24:60:SS")," Starting interference jobs",!
	. Do job^job("UpdateLoop^"_DriveRtn,InterfereCnt,"""0,"_GenerateMemDmp_","_Debug_","_oktorungtmpcat_"""")
	. Write $ZDate(^startdh,"24:60:SS")," ",InterfereCnt," interference jobs launched",!
	Write:(0=InterfereCnt) "No interference jobs requested or launched",!
	Do @("UpdateLoop^"_DriveRtn_"(1,.GenerateMemDmp,Debug,oktorungtmpcat)")
	;
	; Wait for all to shutdown
	;
	Set ^quit=1
	Do wait^job
	Quit

;
; Routine to run gtmpcat against this process.
;
RunGtmpcat
	ZSystem "$cms_tools/gtmpcat.sh --memorydump "_$Job_">>&! gtmpcatout-"_$Job_"-"_$ZDate($Horolog,"YEARMMDD-2460SS")_".log"
	Quit

;
; Routine to pre-read the $TEXT for all defined triggers. These triggers are read via indirects which each line in each trigger 
; creates a separate indirect. Pre-read them all so all indirects are created and don't contribute to artificial failures
; with false memory leak detections.
;
TriggerTextInit(DriveRtn,trigcnt)
	New i,x,lbl,cnt,line,tcnt,quit
	Set maxleak=0			; Not NEW'd. Set for all processes here - should be zero memory variance
	Set x=$Text(+1^trigthrashdrv)
	Do:(debug)
	. Write $ZDate($Horolog,"24:60:SS")," Starting triggertextinit pre-load",!
	. Hang 0.5
	Set tcnt=0
	For i=1:1:trigcnt Do
	. Set lbl="Trigger"_i
	. Set line=1
	. Set quit=0
	. For cnt=1:1 Quit:quit  Do
	. . Set line=$Text(@lbl+cnt^@DriveRtn)
	. . If $ZExtract(line,1)'=";" Set quit=1 Quit
	. . Set tcnt=tcnt+1
	Do:(debug)
	. Write $ZDate($Horolog,"24:60:SS")," Completed ",tcnt," triggertextinit pre-loads",!
	. Hang 0.5
	Quit
