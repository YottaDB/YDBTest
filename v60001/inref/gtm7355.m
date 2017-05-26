;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-7355 - TP restart while handling error
; Cover the following cases:
;   1. Implicit TP due to trigger
;   2. Explicit TP due to TSTART
;   3. Same as #1 but with a null $ETRAP set in main level
;   4. Same as #2 but with a null $ETRAP set in main level
;   5. Same as #1 but with a non-NULL $ETRAP set in main level
;   6. Same as #2 but with a non-NULL $ETRAP set in main level
;   7. Similar to #3 but with a trigger that drives a routine that does not exist
;   8. Similar to #5 but with a trigger that drives a routine that does not exist
;
; Note there are 5 flavors of this test using different error trap invocation techniques described below.
;
	Write "Routine not intended to be invoked without selecting one of the three invocation flavors",!
	ZHalt 1
;
; Initialization routine - if debugging test, set "^debug" to 1 to get additional stack dump info at each
; transition point
;
init
	Set ^debug=0
	Quit

;
; The first flavor of this test invokes error handler(s) with GOTO driving etr1 (error trap does TP restart)
;
flavor1
	Write "Flavor 1 selected - Drive error handler with GOTO driving etr1 (error trap does TP restart)",!
	Set ^etrapflavor="Goto etr1^"_$Text(+0)
	Goto main

;
; The second flavor of this test invokes error handler(s) with DO driving etr1 (error trap does TP restart)
;
flavor2
	Write "Flavor 2 selected - Drive error handler with DO driving etr1 (error trap does TP restart)",!
	Set ^etrapflavor="Do etr1^"_$Text(+0)
	Goto main

;
; The third flavor of this test invokes the error handler(s) with a long $ETRAP
;
flavor3
	Write "Flavor 3 selected - Drive error handler entirely within $ETRAP",!
	Set ^etrapflavor="New $ETrap Write !,""** $ETrap (7a) entered: "",$ZStatus,! Set $ETrap="""" ZWrite $TLevel Do:^debug DumpDStack^"_$Text(+0)_" TRestart:($TLevel&(2>$TRestart))  Write ""ZGoto back to main from eror trap"",! ZGoto @^caseend"
	Goto main

;
; The fourth flavor of this test invokes error handler(s) with GOTO driving etr2 (error trap drives $ZInterrupt which does TP restart)
;
flavor4
	Write "Flavor 4 selected - Drive error handler with GOTO driving etr2 (error trap drives $ZInterrupt which does TP restart)",!
	Set ^etrapflavor="Goto etr2^"_$Text(+0)
	Set $ZInterrupt="Do zint^"_$Text(+0)
	Goto main

;
; The fifth flavor of this test invokes error handler(s) with DO driving etr2 (error trap drives $ZInterrupt which does TP restart)
;
flavor5
	Write "Flavor 5 selected - Drive error handler with DO driving etr2 (error trap drives $ZInterrupt which does TP restart)",!
	Set ^etrapflavor="Do etr2^"_$Text(+0)
	Set $ZInterrupt="Do zint^"_$Text(+0)
	; Note fall into main

;
; Main driver routine
;
main
	Do init
	Set $ZPiece(stars,"*",82)=""
	;
	; Drive all of the cases
	;
	Set ^entrylvl=$ZLevel
	Set $ETrap="Do mainerr^"_$Text(+0)_" Quit"
	For case=1:1:8 Do
	. Set ^case=case			; While not NEW'd below, may be needed in a trigger
	. Write !,stars,!
	. Write !,"Starting case ",case,!
	. New (case)
	. Do @("case"_case)
	. Write "Case ",case," complete",!
	Write !,stars,!
	Write !,"All tests completed",!
	Quit

;
; Case 1: Implicit TP due to trigger
;
case1
	Set $ZTrap="Do casehndlr^"_$Text(+0)
case1a
	Do case1b	; Create a frame underneath the one that will drive errors and such to prevent premature exit
	   		; (at least in some of these test cases).
	Quit
case1b
	Kill ^x
   	Set %=$ZTRIGGER("ITEM","-*")
   	Set %=$ZTRIGGER("ITEM","+^x -command=Set -xecute=""Do trigdo^"_$Text(+0)_"""")
	Set ^caseend=$ZLevel_":case1end"
   	Set ^x="value"
case1end
   	Quit

;
; Case 2: Explicit TP due to TSTART
;
case2
	Set $ZTrap="Do casehndlr^"_$Text(+0)
case2a
	Do case2b	; Create a frame underneath the one that will drive errors and such to prevent premature exit
	   		; (at least in some of these test cases).
	Quit
case2b
	TStart ():serial
	Write:($TLevel&(0<$TRestart)) "(Re)"
       	Write "Starting transaction",!
	Set ^caseend=$ZLevel_":case2end"
       	Do sub1
case2end
	TRollback:($TLevel)
       	Quit

;
; Case 3: Same as #1 but with a null $ETRAP set in main level
;
case3
	New $ETrap
	Set $ETrap=""
	Goto case1a

;
; Case 4: Same as #2 but with a null $ETRAP set in main level
;
case4
	New $ETrap
	Set $ETrap=""
	Goto case2a

;
; Case 5: Same as #1 but with a non-NULL $ETRAP set in main level
;
case5
	Set $ETrap="Do casehndlr^"_$Text(+0)
	Goto case1a

;
; Case 6: Same as #2 but with a non-NULL $ETRAP set in main level
;
case6
	New $ETrap
	Set $ETrap="Do casehndlr^"_$Text(+0)
	Goto case2a

;
; Case 7: Similar to #3 but with a trigger that drives a routine that does not exist
;
case7
	New $ETrap
	Set $ETrap=""
	Do case7a	; Create a frame underneath the one that will drive errors and such to prevent premature exit
	   		; (at least in some of these test cases).
	Quit
case7a
	New $ETrap
   	Set $ETrap=^etrapflavor
	Kill ^x
      	Set %=$ZTRIGGER("ITEM","-*")
       	Set %=$ZTRIGGER("ITEM","+^x -command=Set -xecute=""Do ^notexist""")
	Set ^caseend=$ZLevel_":case7end"
       	Set ^x="value"
case7end
	TRollback:($TLevel)
        Quit

;
; Case 8: Similar to #5 but with a trigger that drives a routine that does not exist
;
case8
	New $ETrap
	Set $ETrap="Do casehndlr^"_$Text(+0)
	Do case7a	; Create a frame underneath the one that will drive errors and such to prevent premature exit
	   		; (at least in some of these test cases).
	Quit

;
; Routine driven either by a trigger or called from within transaction depending on case
;
trigdo
sub1
	New $ETrap
   	Set $ETrap=^etrapflavor
   	;Set $ECode=",U14,"		; Avoiding for now since this error will change in future and prefer not to re-do reference file
	Set xx=yy			; Should cause an undef error
   	Quit

;
; Error handler for main routine should errors unwind all the way back to it
;
mainerr
	New $ETrap,$EStack
	Write !,"** mainerr: Case ",^case," unwound to main drive routine: ",$ZStatus,!,"Case ",^case," complete",!
	ZWrite $TLevel
	Do:^debug DumpDStack
	TRollback:($TLevel)
	Set $ECode=""
	Write "ZGoto back to main from mainerr^",$Text(+0),!
	ZGoto ^entrylvl	; Should respin loop

;
; Handler set at top of case level (may be $ZTRAP or $ETRAP).
;
casehndlr
	New newlvl,zgototo
	Write !,"** casehndlr: Error in case ",^case,": ",$ZStatus,!
	ZWrite $TLevel
	Do:^debug DumpDStack
	Set $ECode=""
	TRollback:($TLevel)
	;
	; We can find our selves in the interesting position where the case has been unrolled (in test 7) so we cannot
	; ZGOTO back to that level. If we detect that case, do what mainerr does instead to return to the case loop.
	;
	Set newlvl=$ZPiece(^caseend,":",1)
	If ($ZLevel<newlvl) Do  ZGoto ^entrylvl
	. Write "Detected unwind past where we can return to case - returning to case loop instead",!
	Write "ZGoto back to main from casehndlr^",$Text(+0),!
	ZGoto @^caseend

;
; Handler driven for intentional error in trigger or transaction routine (not used in flavor 3 since error handler is
; totally contained within the $ETRAP itself).
;
etr1
	New $ETrap
	Write !,"** Error trap etr1^",$Text(+0)," entered: ",$ZStatus,!
	Set $ETrap=""
	ZWrite $TLevel
	Do:^debug DumpDStack
	;
	; Creating a TP restart explicit or implicitly  doesn't matter for this issue but explicitly is definitely easier
	;
	TRestart:($TLevel&(2>$TRestart))
	Write "ZGoto back to main from etr1^",$Text(+0),!
	ZGoto @^caseend

;
; Hander similar to etr1 but instead of driving the TRestart here, we invoke a $ZInterrupt in which to drive the TP restart.
;
etr2
	New $ETrap,i
	Write !,"** Error trap etr2^",$Text(+0)," entered: ",$ZStatus,!
	Set $ETrap=""
	ZWrite $TLevel
	Do:^debug DumpDStack
	;
	; Invoke $ZInterrupt frame
	;
	Set waitforint=0
	ZSystem "mupip intrpt "_$Job_" >>& zintr.out"
	For i=1:1:100000 Quit:(0<waitforint)  Hang 0.01	; Loop waiting for interrupt
	Write:(100000=i) "Failed to get $zinterrupt",!
	Write "Returned from $ZInterrupt - ZGoto back to main from etr2^",$Text(+0),!
	ZGoto @^caseend

;
; Routine driven by $ZInterrupt (flavors 4 and 5).
;
zint
	New $ETrap
	Set $ETrap="Do zintetr2^"_$Text(+0)
	Write !,"** $ZInterrupt trap zint^",$Text(+0)," entered",!
	ZWrite $TLevel
	Set waitforint=waitforint+1
	Do:^debug DumpDStack
	;
	; Creating a TP restart explicit or implicitly  doesn't matter for this issue but explicitly is definitely easier
	;
	Do:($TLevel&(2>$TRestart))
	. Write "Driving TP Restart",!
	. TRestart
	Write "Returning from zint^",$Text(+0),!
	Quit

;
; Routine to handle errors during $ZInterrupt processing
;
zintetr2
	New $ETrap,i
	Write !,"** Error trap zintetr2^",$Text(+0)," entered: ",$ZStatus,!
	Set $ETrap=""
	ZWrite $TLevel
	Do:^debug DumpDStack
	Write "Clearing $ECODE and Quitting from this level",!
	Set $ECode=""
	Quit

;
; Dump $STACK() contents and real stack
;
DumpDStack
	New stx,frames,rstk,maxlvl
	Set frames=$Stack(-1)+1
	Write "Stack at point of error (",frames," frames) with $ECode=",$ECode,!
	Write "Frame #",?10,"Entry Point",?30,"$ECode",?53,"Mode",?68,"M-Code",!
	For stx=frames:-1:0 Do
	. Quit:((""=$Stack(stx,"PLACE"))&(""=$Stack(stx,"ECODE"))&(""=$Stack(stx,"MCODE")))
	. Write stx,?10,$Stack(stx,"PLACE"),?30,$Stack(stx,"ECODE"),?53,$Stack(stx),?68,$Stack(stx,"MCODE"),!
	Write "End of $Stack() - Actual stack:",!
	Write "Frame #",?10,"Entry Point",!
	ZShow "S":rstk
	Set maxlvl=$Order(rstk("S",99999),-1)
	For stx=1:1:maxlvl Do
	. Write (maxlvl-stx),?10,rstk("S",stx),!
	Quit
