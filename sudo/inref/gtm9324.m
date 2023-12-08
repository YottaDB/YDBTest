;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-9324 - These routines play supporting roles in the sudo/gtm9324 test
;

;
; Entry point testA
;   This startups of ZSTEP tracing while going through a loop waiting for a $ZINTERRUPT. Once
;   the interrupt occurs, the routine exits. A validation of the created log is done later.
;
testA
	do ^sstep
	set $zinterrupt="do handleint"
	set ^loopend=0
	for loopcnt1=1:1 set ^loopcnt1=loopcnt1 quit:^loopend  hang .1
	;
	; Add a few lines of code to trace to verify zstep was restored
	;
	set x=42
	set y=43
	set z=x+y
	quit

;
; Entry point testB
;   This startups of ZSTEP tracing while going through a loop waiting for a $ZTIMEOUT interrupt.
;   Once the interrupt occurs, the routine exits. A validation of the created log is done later.
;
testB
	do ^sstep
	;
	; Setup $ZTIMEOUT to pop in 1 second from now
	;
	set $ztimeout="1:do handleint"		; Assuming we can get into this loop in 1 second
	set ^loopend=0
	for loopcnt2=1:1 set ^loopcnt2=loopcnt2 quit:^loopend  hang .1
	;
	; Add a few lines of code to trace to verify zstep was restored
	;
	set x=42
	set y=43
	set z=x+y
	quit

;
; Routine handleint
;   This routine is called when the 'interrupt' ($ZINTERRUPT or $ZTIMEOUT) occurs and sets the loopend flag.
;
handleint
	set ^loopend=1
	write "Interrupt routine entered - setting loop terminator",!
	set $zinterrupt=""			; Shut off further interrupts of either sort
	set $ztimeout=-1
	quit

;
; Routine to serve as the target for a ZBREAK command (never run)
;
zbrktarget
	quit

;
; Routine to verify we can execute a ZSTEP during (ZBREAK will be restricted). We should see a trace of this program
; and not a RESTRICTEDOP error. This routine is run with 2 ZSTEP commands and a ZCONTINUE command as a heredoc.
;
verifyzstep
	break
	set x=42
	write !,"Reached end of verifyzstep routine",!
	quit

;
; While reviewing this test, a similar update to the one that caused assert failures when ZBREAK was restricted and
; we did a ZSTEP was located in op_zstepret.c This routine will do a ZSTEP OUTOF command and verify there is not
; assert failure. Test was largely taken from r120 suite (zstoutof.m)
;
verifyzstepoutof
	set x1=$$helper
	quit
helper()
	do zstepoutof
	set x2=$$y
	quit x2
y()
	set xx="x3",x3=""
	quit @xx
zstepoutof	;
	set $zstep="write:$x ! write $zpos,?30,"":"" zprint @$zpos zstep outof"
	zb zstepoutof+3:"zstep into"
	write !,"Stepping STARTED",!
	quit

