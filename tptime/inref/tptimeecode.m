;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to test interactions between tptimeout, $ECODE, etc (C9905-001073)
;
; Run the following subtests:
;
;   1. ECODECLR - Verify a TP timeout is not echoed until after $ECODE gets cleared
;   2. TPUNW    - If transaction is unwound before $ECODE gets cleared, no timeout happens
;   3. ZTRAPSET - If in a deferred timeout, $ZTRAP gets set (meaning $ECODE is no longer
;                 relevant), the timeout should pop immediately.
;   4. UNWZTRAP - If a stack frame unwind puts $ZTRAP into play because it was restored,
;      		  the timeout should pop immediately.
;   5. JINTEXIT - Verify a TP timeout is not allowed to continue until we come out of
;                 a job interrupt.
;
; Note since this test is doing timing, a loaded system can adversely affect performance and
; potentially even correct operation. Note also that while this test mentions VMS, it is NOT
; as of this date (12/2011) supported there as there are interaction issues with timers and
; out-of-band (both use the same event flag).
;
; The "ts" variable below can be useful in debugging as it timestamps most messages this
; subtest produces. One can see from the timestamps exactly when what fired which, with
; this type of test can be useful in determining the exact timings of messages. We leave
; it off in the testsystem though as timestamp variances make reference files rather tedious.
; Can be especially useful for debugging when combined with DEBUG_TPTIMEOUT_DEFERRAL and
; DEBUG_DEFERRED_EVENT compile defines to enable GTM tracing of outofband events.
;
	do ^ssteplcl
	Set vms=($ZVersion["VMS")
	Set ts=0	; Timestamps: 0=no, 1=yes (1 for debugging - 0 makes reference file readable)
	Set daysecs=24*60*60
	For tst="ecodeclr","tpunw","ztrapset","unwztrap",$Select('vms:"jintexit",1:"") Do
	. Quit:(""=tst)		; Ignore nullified UNIX-only test
	. ;
	. ; Set up tp timeout and initialize TP transaction
	. ;
	. Set $ETrap="Do errortrap"	; Reset for each iteration
	. Write !!,"----------------------------------------------------------",!!
	. Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Subtest ",tst," starting",!
	. Set minelap=15
	. Set maxelap=30
	. Set $ZMaxtptime=10	; 10 seconds
	. Set (hadintr,error,ztrapset)=0;
	. TStart ():(Serial:Transaction="BA")
	. Set tpstarttime=$Horolog
	. Set tst=$Translate(tst,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
	. Do @tst
	. Set tpendtime=$Horolog
	. TRollback:(0<$TLevel)
	. Set duration=$$Elapsed(tpstarttime,tpendtime)
	. If (duration<minelap)!(duration>maxelap) Do
	. . Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Subtest ",tst," failed - duration was ",duration," seconds - min: ",minelap,"  max: ",maxelap,!
	. . Set error=1
	. If expectintr&'hadintr Do
	. . Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Subtest ",tst," failed - expected TPTIMEOUT but did not get one",!
	. . Set error=1
	. If 'expectintr&hadintr Do
	. . Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Subtest ",tst," failed - did not expect a TPTIMEOUT but received one",!
	. . Set error=1
	. Write:(0=error) $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")," Subtest ",tst," completed successfully ",$Select(expectintr:"(got interrupt)",1:"(interrupt cancelled)"),!
	Write !
	; The "do ^ssteplcl" call above would have initiated recording M line activity in the local variable "%ssteplcl".
	; Move that over to a global variable so we have it persist as debug information in case of a failure.
	merge ^%sstepgbl=%ssteplcl
	Quit

;
; Note when the following subtest routines set $ECODE, this trips an error (SETECODE). Having an initial $ECODE value
; is required for these tests. When the error trips, we head off to error trap which will call back to the test routine.
;
; Note that all "For" loops below have the "Hang" commands in a separate line (inside a dotted "do") instead of in the same
; line to help "do ^ssteplcl" record the time each "Hang" started execution as that tool only records at each M line granularity.
;
; ecodeclr - Generate an error (by setting $ECODE). Value is not important but it generates a SETECODE error. 5 seconds after
; 	     the tptimeout should kick in, we clear $ECODE and verify it pops in the next few seconds.
ecodeclr
	Set expectintr=1
	Set callback="ecodeclrcont"
	Set $ECode=",Z150381146,"	; Should prevent timeout until we allow it
	Quit
ecodeclrcont
	New i
	For i=1:1:15 do
	. Hang 1		; Gets us safely past the timeout time. TPTimeout on VMS interrupts timer so make it
	    	     	  		; .. somewhat graduated so entire timer is not thrown away
	Set $ECode=""			; Allows the tp timeout to pop
	For i=1:1:16 do
	. Hang 1		; Give it time and opportunity to pop
	Quit

;
; tpunw    - Starts out like ecodeclr but instead before clearing $ECODE, we rollback the transaction which should cancel the
; 	     timeout. Only then clear $ECODE.
;
tpunw
	Set expectintr=0
	Set callback="tpunwcont"
	Set $ECode=",Z150381146,"	; Should prevent timeout until we allow it
	Quit
tpunwcont
	For i=1:1:15 do
	. Hang 1		; Gets us safely past the timeout time. TPTimeout on VMS interrupts timer so make it
	    	     	  		; .. somewhat graduated so entire timer is not thrown away
	TRollback			; Should prevent timeout
	; The TROLLBACK above would have erased the TPTIMEOUT deferred "outofband" action. As part of that it would also
	; remove the $ZSTEP action as both are treated as "outofband" (current YottaDB misfeature). Work around by
	; redeclaring $ZSTEP (hence the reinvocation of "do ^ssteplcl" below).
	do ^ssteplcl
	Set $ECode=""
	Hang 5				; Timeout should never occur
	Quit

;
; ztrapset - Starts out like ecodeclr but we set $ZTRAP and clear $ECODE on the same line. If not on the same line, the
;            error is treated as nested and the stack is unwound back to the SET $ECODE and rethrows the error.
;
ztrapset
	Set expectintr=1
	Set callback="ztrapsetcont1"
	Set $ECode=",Z150381146,"	; Should prevent timeout until we allow it
	Quit
ztrapsetcont2
	Quit
ztrapsetcont1
	New i
	For i=1:1:15 do
	. Hang 1		; Gets us safely past the timeout time. TPTimeout on VMS interrupts timer so make it
	    	     	  		; .. somewhat graduated so entire timer is not thrown away. Should timeout at 10 sec.
	New $ZTrap
	Set $ZTrap="Do errorztrap",$ECode=""	; Should release the timeout immediately
	For i=1:1:16 Quit:hadintr  do
	. Hang 1
	Quit

;
; unwztrap - Starts out like ecodeclr but create a stack frame where $ZTRAP is set, then another frame where $ETRAP is set.
; 	     We wait for the timeout to pop (which only defers when $ETRAP is set)
;
unwztrap
	Set expectintr=1
	Set callback="unwztrapcont1"
	Do				; Provides an extra stack level so test returns normally - else it returns
	.				; .. into the main driver routine driving the wrong error handler.
	. Set $ECode=",Z150381146,"	; Should prevent timeout until we allow it
	Quit
unwztrapcont1
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_"unwztrapcont1 entered",!
	Do
	. New $ZTrap
	. Set $ZTrap="Do errorztrap2"	; Puts frame with $ZTRAP set on stack
	. Do
	. . New $ETrap
	. . Set $ETrap="Do errorztrap2"	; Must be an ETRAP to initially defer - just let it unwind into the $ZTRAP frame
	. . For i=1:1:15 do
	. . . Hang 1		; Gets us safely past the timeout time. TPTimeout on VMS interrupts timer so make it
	. . .  	     		; .. somewhat graduated so entire timer is not thrown away
	. . Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Leaving $ETRAP block to $ZTRAP block - should allow handler to be be driven",!
	. Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Returned to frame with $ZTRAP set",!
	Hang 2
	Quit

;
; jintexit - Instead of putting ourselves in an error condition, put ourselves in a job interrupt and make sure
;            the interrupt is not reflected until we come out of the job interrupt. This test does not run on VMS
;	     due to VMS's somewhat less than robust jobinterrupt.
;
jintexit
	Set expectintr=1
	Set $ZInterrupt="Do jintexitcont"
	ZSystem "$gtm_dist/mupip intrpt "_$Job_">& jobinterrupt_invocation.txt"
	For i=1:1:30 Quit:hadintr  do
	. Hang 1
	;
	; The job interrupt should be caught in the FOR loop above. The job interrupt should also catch the tptimeout
	; which should be driven immediately on return from the job interrupt so the WRITE below should never trigger.
	;
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Returned from job interrupt (should not see this)",!
	Quit
jintexitcont
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Job interrupt jintexitcont entered (TP timeout in 10 seconds)",!
	Hang 20	   	     		; Should timeout at 10 seconds
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" Exiting jobinterrupt",!
	Quit


;;;;;;;;;;;;;;;;;;;;;;;;;
;			;
; Secondary subroutines ;
; 	    		;
;;;;;;;;;;;;;;;;;;;;;;;;;

;
; errortrap - If the error is for TPTIMEOUT: Clear $ECODE and set hadintr
; 	    - If the error is for SETECODE:  Set by the test. For these we call back to the running test.
;           - Otherwise, treat as an error, zshow, and halt..
;
errortrap
	New errornum
	Set errornum=$ZStatus+0
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" errortrap: error tripped: ",$ZStatus,!
	If (errornum=150379506) Do @callback Quit	     ; SETECODE error
	; Handling the TPTIMEOUT error would clear any active $ZSTEP actions too (current YottaDB misfeature) as they both are
	; considered as "outofband" events. Work around by redeclaring $ZSTEP (hence the reinvocation of "do ^ssteplcl" below).
	If (errornum=150377322) Set hadintr=1,$ECode="" do ^ssteplcl Quit  ; TPTIMEOUT error
	ZShow "*"
	Halt

;
; errorztrap - Only handle the TPTIMEOUT error here appropriately for $ZTRAP
;
errorztrap
	New errornum
	Set errornum=$ZStatus+0
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" errorztrap via : error tripped: ",$ZStatus,!
	; See comment in "errortrap" entryref for why "do ^ssteplcl" is done again.
	If (errornum=150377322) Set hadintr=1,$ECode="" do ^ssteplcl ZGoto -3:ztrapsetcont2	; TPTIMEOUT : Should send us back
	Write !,$Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" errorztrap: Unexpected error",!
	ZShow "*"
	Halt

;
; errorztrap2 - Shouldn't ever be called but here just in case
;
errorztrap2
	Write $Select(ts:$ZDate($Horolog,"24:60:SS"),1:"")_" errorztrap2: entered via ",$Select((""=$ETrap):"$ZTrap",1:"$ETrap"),": ",$ZStatus,!
	ZShow "*"
	Break
	Halt

;
; Compute elapsed time
;
Elapsed(start,end)
	New startday,endday,startsec,endsec,elapsec,elapday
	Set startday=$ZPiece(start,",",1)
	Set startsec=$ZPiece(start,",",2)
	Set endday=$ZPiece(end,",",1)
	Set endsec=$ZPiece(end,",",2)
	Set:(endsec<startsec) endday=endday-1,endsec=endsec+daysecs
	Set elapsec=endsec-startsec
	Set elapday=endday-startday
	Set elapsec=elapsec+(elapday*daysecs)
	Quit elapsec
