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
; Test for GTM-9036 - Test SIGHUP device parameter making sure we can trap it with ^C handler if enabled for $P
;
gtm9036
	set hangincr=.25
	set maxhang=2
	set errors=0
	set seensig=0
	; Determine if we are running on GT.M or YottaDB so we know how to send ourselves a signal. The signal number
	; for SIGHUP is 1 on Linux but if ever we run on another platform, that number could change. Therefore we favor
	; use of YottaDB's extension to GT.M that allows the signal to send via $ZSIGPROC() to be specified by name
	; (e.g. "SIGHUP" or even just "HUP"). So try to use a YottaDB-only extension (reference to $ZYRELEASE) and if
	; not found, we're in GT.M.
	set inyottadb=1			; Our assumption
	do
	. new x,$etrap
	. set $etrap="set inyottadb=0,$ecode=""""" ; Do this in a sub block that can be unwound on error
	. set @("x=$zyrelease")
	; The 'inyottadb' variable should be appropriately set now - reset $etra to what we need for the rest of
	; this routine.
	set $etrap="zwrite $zstatus zhalt -1"
	write "# Test for GTM-9036 - verify SIGHUP is trapped if enabled",!,"#",!
	; Send ourselves a SIGHUP having done nothing and expecting nothing to happen (unless gtm_hupenable has
	; been set to TRUE in which case we expect this to fail).
	write "# First verify we do NOT get an interrupt having NOT enabled SIGHUP when a SIGHUP is sent to us",!
	if $zsigproc($job,$select(inyottadb:"SIGHUP",1:1))
	do hangfor(2)
	write "Success - No interrupts/errors due to SIGHUP coming in",!
	;
	; We are about to send a SIGHUP we want to be caught and processed by YottaDB. After YottaDB receives
	; this signal, it will believe the terminal (aka $P) is GONE so will terminate at any IO it does. So
	; open a file that we will send everything to from now on. Later this file will be cat'd into the test log.
	set fn="gtm9036_post_exception.log"
	open fn:new
	; Now enable SIGHUP on $P and see what happens
	write "#",!,"# Now enable SIGHUP and see if we see SIGHUP when it is sent again",!,"#",!
	use $p:(exception="do gotexpectedexception^"_$text(+0):hupenable)
	if $zsigproc($job,$select(inyottadb:"SIGHUP",1:1))
	do hangfor(2)
	;
	; See if we succeeded
	if seensig write "Success - SIGHUP was processed in our handler",!!
	else  do
	. write "Fail - we did not see our error/interrupt handler get driven",!!
	. set errors=error+1
	;
	; Disable the SIGHUP handling to see what happens and whether we can access $P again or not
	set seensig=0				; Reset
	use $p:(exception="do gotunexpectedexception":nohupenable)
	; see where write text goes.
	use fn
	; Send ourselves a SIGHUP having done nothing and expecting nothing to happen
	write "# Now disable SIGHUP handling again and retry the SIGHUP signal to see if it gets caught or not",!
	if $zsigproc($job,$select(inyottadb:"SIGHUP",1:1))
	do hangfor(2)
	; Do some summary stats for our exit
	write:(0=errors) "Success - no unexpected exception occurred",!!
	write:(0'=errors) "Fail - an unexpected exception occurred as noted above",!!
	quit

;
; We are driven due to a SIGHUP - we expect the error in this case to be TERMHANGUP - verify
gotexpectedexception
	new err
	use fn
	set err=$zpiece($zstatus,",",3)		; Get the (hopefully) GTM/YDB-E-TERMHANGUP error
	if err'["-E-TERMHANGUP" do
	. write "# Unexpected exception drove our error/signal handler: ",$zstatus,!
	. zshow "*"
	. zhalt -1
	set seensig=1
	write !,"SIGHUP signal/interrupt has been caught!",!
	write "$ZSTATUS=""",$zstatus,"""",!
	set $ecode=""	; clear error
	quit

;
; We are driven due to an error (or signal) we did not expect
gotunexpectedexception
	set errors=errors+1
	write "Unexpected exception caught in gotunexpectedexception^",$text(+0),": ",$zstatus,!
	set $ecode=""
	quit

;
; Routine to sleep in increments to allow signal to be handled. The signal is handled as a ^C so while the signal
; is serviced immediately, the outofbound handing for ^C needs for a new line of code or new loop iteration to occur
; before the signal is actually handled. This is best done with this incremental sleep where we loop on short sleeps
; giving the pending signal lots of opportunities to trip.
hangfor(secs)
	new x
	for x=hangincr:hangincr:maxhang do
	. quit:seensig
	. hang hangincr
	quit
