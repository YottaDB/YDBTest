;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
;       Copyright 2013 Fidelity Information Services, Inc	;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-7642 - TRESTART outside TP should give TLVLZERO error
;            (note v60001/gtm7355 already tests if in TP)
;
; V6.0-001 broke this when inside an error handler.
;
	Set debug=0				; Enable to cause print-traces as routines are invoked
	Set $ETrap="Do err^"_$Text(+0)
	Set variation=1
	Do trestartcheck			; Do TRESTART check not in TP and not in error handler
	Do inerrchk				; Do TRESTART check not in TP but in an error handler
	Quit

;
; Routine to do TRESTART check not in TP but in an error handler. This has some interesting side effects because
; the TLVLZERO error we expect to get will then be a nested error which means error handling will unwind back to
; the frame the first error was thrown in before unwinding it and only THEN rethrowing the 2nd error so make sure
; we have sufficient stack frames built up to survive that.
;
; Note this also means this routine has to do the pass/fail check done in trestartcheck in the first test.
;
inerrchk
	Do
	. Do
	. . Write:debug "Entered inerrchk",!
	. . Set $ETrap="Do inerror^"_$Text(+0)
	. . Set x=1/0      ; Drive error to put us in error handler
	. . Write "Don't expect to get back here either",!
	Write:debug "Re-entered inerrchk with $ZLevel=",$ZLevel," and $ZSTatus=",$ZStatus,!
	Do:debug DumpDStack
	Write "Test #",variation,$Select(gottlvl0:" PASS",1:" FAIL"),!!
	Quit

;
; In error handler to do 2nd check
;
inerror
	Write:debug "Entered inerror with $ZLevel=",$ZLevel," and $ZSTatus=",$ZStatus,!
	Do:debug DumpDStack
	Set $ETrap="Do err^"_$Text(+0)
	Set variation=2
	Do trestartcheck
	;
	; Since the trestartcheck will create a nested error condition, we won't return here but will
	; unwind to the main routine.
	;
	Write "Don't expect to get here",!
	Quit

;
; Drive TRESTART and verify we got the error we expect
;
trestartcheck
	Write:debug "Entered trestartcheck routine for variation ",variation,!
	Do:debug DumpDStack
	Set gottlvl0=0
	Do		; Add stack level as lose a level when error unwinds
	. TRestart
	Write "Test #",variation,$Select(gottlvl0:" PASS",1:" FAIL"),!!
	Quit

;
; Error handler - expect to see TLVLZERO errors.
;
err
	Write:debug "Entered err handler with $ZLevel=",$ZLevel," and $ZSTatus=",$ZStatus,!
	Do:debug DumpDStack
	If ($ZStatus["TLVLZERO") Set gottlvl0=1 Set $ECode="" Quit
	Write !,"Received unexpected error",!
	ZShow "*"
	ZHalt 1

;
; Dump $STACK() contents and real stack
;
DumpDStack
	New stx,frames,rstk,maxlvl
	Set frames=$Stack(-1)+1
	Write "Stack from $STACK() (",frames," frames) with $ECode=",$ECode,!
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
	Write !
	Quit
