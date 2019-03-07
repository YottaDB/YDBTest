;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2014 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7547a
	; $etrap needs to retain the older value and must not be null after a NEW
	; TEST PART 1 - Original test case reported by a customer
	; If the "halt" string is unchanged after the NEW, it's a pass
	xecute "new $etrap set $etrap=""halt"" new $etrap write:$etrap=""halt"" ""gtm7547a1 PASS!"",!"
	; TEST PART 2 - $etrap in action
	set $etrap=""
	; Should still be null after executing below
	new $etrap
	; Put the $etrap code in a local for later comparison
	set saveetrap="new $etrap goto final"
	; Set $etrap and trigger an divide-by-zero error
	set $etrap=saveetrap
	write 1/0
	quit
final
	; The $etrap should take us here. If $etrap is unchanged after the NEW in $etrap, it's a pass
	write:$etrap=saveetrap "gtm7547a2 PASS!",!
	quit

gtm7547b
	; new $etrap, new $ztrap stacks the active condition handler
	; $ztrap=B by default
	do ; create a new frame
	.	new $etrap ;$etrap is now in control
	.	write:($ztrap'="") "gtm7547a FAIL! ztrap should be null because $etrap is in control",!
	.	set $ztrap="do junkb"
	.	quit
	; Here, although $etrap was NEWed, $ztrap should have been saved
	write:("B"=$ztrap)&(""=$etrap) "gtm7547b PASS!",!
	quit

gtm7547c
	; Verify setting $etrap does not save $ztrap
	; $ztrap=B by default
	do ; create a new frame
	.  set $etrap="do junkc" ; This nullifies $ztrap without saving it first
	.  quit
	; Here the SET $etrap should have cleared $ZTRAP and $ETRAP should still be in effect
	write:(""=$ztrap)&("do junkc"=$etrap) "gtm7547c PASS!",!
	quit

gtm7547d
	; Verify setting $ztrap saves $etrap
	; $ztrap=B by default
	set $etrap="do junkd1"
	do ; create a new frame
	.  set $ztrap="do junkd2" ; This should save $etrap in the stack
	.  quit
	write:(""=$ztrap)&("do junkd1"=$etrap) "gtm7547d PASS!",!
	quit
callin
	write 1/0
	quit
