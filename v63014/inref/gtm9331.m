;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm9331a
	write "# GTM-9331 - Verify that an external call driven while a timer is set and if that external call",!
	write "#            messes with signal handling causing the timer expire to occur and be ignored since",!
	write "#            it was not handled with the GTM/YottaDB timer handler.",!,"#",!
	write "#            This test uses $ZTIMEOUT as an easily settable timer that while it is running, we",!
	write "#            can go off and do other things. Such things are more difficult with things like",!
	write "#            the HANG command where we don't get control again until the HANG is complete.",!
	for i=1:1:2 do		; Run 2 test cycles
	. set sawZTimeout=0
	. write:i=1 !,"# First test using external call sigwait1() which has SIGSAFE defined on the external call (expect lost timer wakeup)",!
	. write:i=2 !,"# Second test using external call sigwait2() which does NOT have SIGSAFE defined on the external call",!
	. set $ztimeout="1:do gottimeout"
	. ; Timer now running - call external call to waste some time and wait for timer to pop
	. set sigPopped=$select(i=1:$&sigwait1(10),1:$&sigwait2(10))
	. do genmessages
	quit

;
; Routine driven when $ztimeout sleep expires.
;
gottimeout
	set sawZTimeout=1
	write "*** $ZTIMEOUT popped (in $ZTIMEOUT routine)",!
	quit

;
; Routine to print success/fail type messages
;
genmessages
	write:sigPopped "The external call saw the timer pop",!
	write:'sigPopped "The external call did NOT see the timer pop - there's some sort of problem",!
	write:sawZTimeout "The $ZTIMEOUT fired correctly!!",!
	write:'sawZTimeout "The $ZTIMEOUT was not recognized or driven - lost timer wakeup",!
	quit
