;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to cover the first subissue of this test: The original problem was that there is was small window during
; the execution of a SET $ZTIMEOUT where the current $ZTIMEOUT is being disabled by setting it to a -1 but while
; that is running, the timer pops to drive that $ZTIMEOUT. On versions prior to r1.36/V63014, this could cause the
; pop of the $ZTIMEOUT to occur over and over again in a loop. V63014 fixed this issue and added a white box test
; to allow the simulation of the timer pop while the disable command was running and verify it dealt with the issue
; correctly.
;
subissue1
	set sigwait=3					; Wait in seconds for an expected signal to be delivered
	set timeoutfired=0
	;
	; Now, on to the testing
	;
	write !,"# Subissue1: Set a timeout for 2 seconds from now, then try to disable the ztimeout. The",!
	write "#            white box case that was enabled will cause the clearing of the ztimeout to wait",!
	write "#            for 4 seconds so the timer for that ztimeout can pop. The signal popping in this",!
	write "#            window was what previous caused the ztimeout to loop in earlier versions.",!
	write !,"# Setup our ztimeout (expect tracing from white box case).",!
	set $ztimeout="2:do ztimcode"
	write !,"$ZTIMEOUT set - now cause it to unset with whitebox case WBTEST_ZTIM_EDGE setup",!
	set $ztimeout=-1
	;
	; If we made it back without assert failing, we succeeded!
	;
	write !,"Subissue1: completed",!
	quit

;
; Routine that needs to exist because of the call to it from the $ZTIMEOUT but is otherwise not used.
;
ztimcode
	write "ztimcode: Entering via $ztimeout",!
	;
	; Nothing really to do here.
	;
	write "ztimcode: Leaving..",!
	quit

;
; Routine to cover the second subissue of this test: The original problem was that if the code vector for a $ZTIMEOUT
; had invalid code in it, the SET of it would generate an error but afterwards, the code vector would be blank. It did
; not retain the original valid value. This subtest verifies the old value is retained.
;
subissue2
	;
	; Try to set the ztimeout to an invalid code vector - handle the error, then verify the old value still there
	;
	set $etrap="do goterr^gtm9329 quit"
	set $ztimeout="5:do ztimcode"
	set savtimeout=$ztimeout
	write "$ZTIMEOUT before attempting to set an invalid code vector: ",$ztimeout,!
	do						; Create stack level for $etrap to unwind
	. set $ztimeout="1:THIS-IS-BAD-CODE"
	write "$ZTIMEOUT after attempting to set an invalid code vector: ",$ztimeout,!
	write !,"Subissue2: ",$select(savtimeout=$ztimeout:"succeeded",1:"failed - $ZTIMEOUT invalidly changed given invalid code vector"),!
	quit

;
; Routine to catch the error subissue2 will throw and ignore it so long as it is the expected error
;
goterr
	set emsg=$zstatus
	if +emsg'=150373050 do	; If not the INVCMD error we were expecting, error out appropriately
	. write "Unexpected error: ",emsg,!!
	. zshow "*"
	. zhalt 1
	set $ecode=""		; clear pending error
	write "Got expected error from attempted compile of bad $ZTIMEOUT code",!
	quit

