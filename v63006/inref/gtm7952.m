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
gtm7952
	write "# gtm7952: This test is a test of the SIGSAFE keyword in the external call table. In this test,",!
	write "# what we do first is drive the external call that does NOT have the SIGSAFE keyword first as it",!
	write "# should notice the handler was changed and fix it but the second call drives the SIGSAFE keyword",!
	write "# so doing that does not check that the SIGALRM handler has been changed so the subsequent HANG",!
	write "# actually stays HUNG until the process gets shot.",!
	write "#",!
	write "# Note - the description above only applies to GT.M builds. While the GT.M build uses the internal",!
	write "# timer facility, a YottaDB build uses a different timing mechanism so never sees the HANG that",!
	write "# GT.M versions see. So to see the hang, the test needs to run on a GT.M build.",!
	;
	; Note - YottaDB has an entirely different method of sleeping that does NOT use our internal timers so
	;      	 YottaDB works for this test while GTM, using internal timers to implement the hang, fails.
	set ^waittime=5		; Length of our HANG
	for test=1:1:2 do	; Run 2 test cycles
	. write:test=1 !,"# First test using external call sigdisable2() which does NOT have SIGSAFE defined on the external call "
	. write:test=1 "(expect no errors)",!
	. write:test=2 !,"# Second test using external call sigdisable1() which has SIGSAFE defined on the external call "
	. write:test=2 "(expect HANG command to hang until killed on GT.M, and no errors on YottaDB)",!
	. ;
	. set ^test=test
	. zsystem "strace -o gtm7952_strace_"_test_".txt $gtm_dist/mumps -run hangtest^gtm7952"
	quit

;
; Routine called to do actual hang test and trace it via strace. These traces will later be scrutinized for indications
; of whether signal processing was avoided on the run that drove the SIGSAFE signed version of the sigdisable() routine.
; Note: expects ^test to be set to an incremented value.
;
hangtest
	;
	; Start the job that will kill us if we get hung up due to HANG wakeup being stolen
	;
	set ^done=0
	if (1=^test) do
	. ;
	. ; For this first test, write out our PID so we can use it to validate TIMERHANDLER messages we find
	. ; so we don't mistakenly pick one up from another parallel test.
	. ;
	. set pidfile="tmrhndlrpid.txt"
	. open pidfile:new
	. use pidfile
	. write $job,!
	. close pidfile
	job @("hangkill^gtm7952("_$job_",^waittime):(output=""gtm7952-"_^test_".mjo"":error=""gtm7952-"_^test_".mje"")")
	set x=$select(^test=1:$&sigdisable1(),1:$&sigdisable2())
	set killerpid=$zjob			; Record the process we job'd off and wait for it to die if the hang succeeded
	set isx8664=$zyrelease["x86_64"		; Only put out hang time for x86_64
	set:isx8664 hangstart=$zut
	hang ^waittime				; See if this hang wakes up
	set:isx8664 hangstop=$zut
	set ^done=1
	do:isx8664
	. set hangtime=hangstop-hangstart
	. set hangsec=hangtime\(1000**2)
	. write "Hang time was ",hangtime,"us (",hangsec," seconds)",!
	;
	; Now make sure the hangkill job we started up has shutdown and wait till it does.
	;
	for j=1:1 quit:0'=$zsigproc(killerpid,0)  hang .5	; Check every half second if it is shutdown
	quit

;
; Routine that runs in a separate process and will kill us if we wait too long. This process should
; not have the same problems the hang process has with timers being largely disabled.
;
hangkill(hangpid,waitsec)
	new i,x
	write "hangkill: Active and sleeping for ",waitsec," seconds",!
	hang waitsec		    	; Wait for how long the hang process should hang
	;
	; Wait a few more seconds (max 300) for the hang process to wakeup and shutdown
	;
	write "hangkill: Sleep up to 300 seconds for the process to indicate it is done",!
	for i=1:1:300 quit:1=^done  hang 1
	write "hangkill: Sleeping complete (in ",i," seconds)- checking hang process now",!
	;
	; Now see if the hang process has completed its HANGs or not
	;
	if ^done write "hangkill: Found target process in complete status so exiting",!
	else  do
	. write "hangkill: Found target process (pid ",hangpid,") in a NOT complete status (hang) so sending it a SIGTERM interrupt",!
	. set x=$zsigproc(hangpid,15) 	; Send SIGTERM - use signal number (15) instead of name so can run on GT.M
	. write:0=x "hangkill: SIGTERM sent to hang process",!
	. ; If the $zsigproc() failed, it is only because the process is gone so we're done too
	;
	; Either hang is already done or we've told it to quit and expect it to so now we need to quit as well.
	;
	quit

