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
gtm9331b
	write "# GTM-9331 - This routine is not really a test of GTM9331 but is a test that was created while",!
	write "#            trying to test GTM9331. It is largely a test of the SIGSAFE keyword in the external",!
	write "#            call table. In this test, what we do first is drive the external call that does NOT",!
	write "#            have the SIGSAFE keyword first as it should notice the handler was changed and fix",!
	write "#            it but the second call drives the SIGSAFE keyword so doing that does not check that",!
	write "#            the SIGALRM handler has been changed so the subsequent HANG actually stays HUNG",!
	write "#            until the process gets shot.",!
	set waittime=5		; Length of our HANG
	for i=1:1:2 do		; Run 2 test cycles
	. write:i=1 !,"# First test using external call sigdisable2() which does NOT have SIGSAFE defined on the external call "
	. write:i=1 "(expect success)",!
	. write:i=2 !,"# Second test using external call sigdisable1() which has SIGSAFE defined on the external call "
	. write:i=2 "(expect HANG command to hang until killed on GT.M, pass on YottaDB)",!
	. ;
	. ; Start the job that will kill us if we get hung up due to HANG wakeup being stolen
	. ;
	. set ^done=0
	. job hangkill^gtm9331b($job,waittime)
	. set x=$select(i=1:$&sigdisable2(),1:$&sigdisable1())
	. set killerpid=$zjob	; Record the process we job'd off and wait for it to die if the hang succeeded
	. set hangstart=$zut
	. hang waittime		; See if this hang wakes up
	. set hangstop=$zut
	. set ^done=1
	. set hangtime=hangstop-hangstart
	. set hangsec=hangtime\(1000**2)
	. write "Hang time was ",hangtime,"us (",hangsec," seconds)",!
	. ;
	. ; Now make sure the hangkill job we started up has shutdown and wait till it does.
	. ;
	. for j=1:1 quit:0'=$zsigproc(killerpid,0)  hang .5	; Check every half second if it is shutdown
	quit

;
; Routine that runs in a separate process and will kill us if we wait too long. This process should
; not have the same problems the main process has with timers being largely disabled.
;
hangkill(mainpid,waitsec)
	new i,x
	write "hangkill: Active and sleeping for ",waitsec," seconds",!
	hang waitsec		    	; Wait for how long the main process should hang
	;
	; Wait a few more seconds for the main process to wakeup and shutdown
	;
	for i=1:1:4 quit:1=^done  hang 1
	write "hangkill: Sleeping complete - checking main process now",!
	;
	; Now see if the main process has completed its HANGs or not
	;
	if ^done write "hangkill: Found main in complete status so exiting",!
	else  do
	. write "hangkill: Found main (pid ",mainpid,") in a NOT complete status so sending it a SIGTERM interrupt",!
	. set x=$zsigproc(mainpid,15) 	; Send SIGTERM
	. write:0'=x "hangkill: $ZSIGPROC() to kill main pid failed with rc ",x,!
	. write:0=x "hangkill: SIGTERM sent to main process",!
	;
	; Either main is already done or we've told it to quit and expect it to so now we need to quit as well.
	;
	quit

