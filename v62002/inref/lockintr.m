;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lockintr
	lock x
	if $&ydbposix.signalval("SIGUSR1",.sigval)
	write "# Launching the child that grabs lock x",!
	job child
	set childpid=$zjob
	write "# Waiting for the child to grab the lock",!
	do ^waitforlockgrab("x")
	write "# Signal the child",!
	if $zsigproc(childpid,sigval)
	write "# Wait for the child to quit",!
	do ^waitforproctodie(childpid)
	quit
child
	; Without the GTM-8282 fix, we wait for 40 seconds (20s in the interrupt handler + 20s for the lock timeout)
	set tolerance=38
	set $zinterrupt="write ""# Interrupted"",! zshow ""S"":srclocation zwrite srclocation hang 20"
	set start=$horolog
	; We assume that any platform should be able to send and process an interrupt within 20 seconds
	; If the box is ultra slow, this test can fail.
	lock x:20
	set end=$horolog
	write "Start="_start,!
	write "End="_end,!
	set diff=$$^difftime(end,start)
	write "Seconds="_diff,!
	if $get(srclocation("S",1))["child+7^lockintr" do  ; Verify the interrupt is received on the lock command as intended
	.	if (diff<=tolerance)&(diff>=20) write "TEST-I-PASS",!
	.	else  write "TEST-E-FAIL the lock has waited "_diff_" seconds. This is out of the acceptable range of [20;"_tolerance_"]",!
	else  write "TEST-E-SLOW The interrupt came too late or never received. Run again when the box is not overloaded",!
	quit
