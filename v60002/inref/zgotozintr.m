;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to send itself a $ZINTERRUPT then attempt to ZGOTO (with entryref)  back to the
; $ZINTERRUPT frame. By dumping the stack at that point we verify this is still considered
; a $ZINTERRUPT frame and that anything the new interrupt calls does NOT *also* become
; and interrupt frame. Also verify that ZSHOW STACK does not ignore non-indirect interrupt
; frames.
;
	Set $ETrap="ZShow ""*"" ZHalt 1"
	Set seenintrpt=0
	Set unix=$ZVersion'["VMS"
	Set $ZInterrupt="Do zinterrupt"
	If unix Do
	. ZSystem "$gtm_dist/mupip intrpt "_$Job_" >& intrpt.txt"
	Else  Set x=$ZSigproc($Job,16)			; Must use zsigproc for VMS
	For i=1:1:3600 Hang 0.1 Quit:seenintrpt		; Waiting for $ZINTERRUPT
	If ('seenintrpt) Do
	. Write "FAIL - Failed to receive interrupt",!
	. ZShow "*"
	. ZHalt 1
	Write !,"Returned from interrupt",!
	Quit

;
; The $ZINTERRUPT routine
;
zinterrupt
	Write "Entered zinterrupt entryref",!
	Set seenintrpt=1
	ZGoto -1:newinterrupt

;
; Routine that re-writes the M stack level that zinterrupt^zgotozintr is currently occupying.
;
newinterrupt
	New stx,frames,rstk,maxlvl
	Write "Stack at re-written interrupt frame:",!
	Set frames=$Stack(-1)+1
	Write !,"Frame #",?10,"Entry Point",?43,"Mode",?68,"M-Code",!
	For stx=frames:-1:0 Do
	. Quit:((""=$Stack(stx,"PLACE"))&(""=$Stack(stx,"ECODE"))&(""=$Stack(stx,"MCODE")))
	. Write stx,?10,$Stack(stx,"PLACE"),?43,$Stack(stx),?68,$Stack(stx,"MCODE"),!
	Write !,"End of $Stack() - Actual stack:",!!
	Write "Frame #",?10,"Entry Point",!
	ZShow "S":rstk
	Set maxlvl=$Order(rstk("S",99999),-1)
	For stx=1:1:maxlvl Do
	. Write (maxlvl-stx),?10,rstk("S",stx),!
	Quit
