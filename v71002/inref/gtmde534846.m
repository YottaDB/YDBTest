;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde534846 ;
	; Set $ETRAP to handle possible YDB-W-TIMEOUT in case $ZTIMEOUT times out.
	; In that case, there is no legitimate failure since 0 cannot be greater than
	; the difference between the duration of a HANG. So, just continue with the
	; test in that case by calling DO ^incretrap.
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set initial(0)=0.1,hangtime(0)=0.045
	set initial(1)=.012345,hangtime(1)=0.005
	set initial(2)=.002345,hangtime(2)=0.001

	; An attempt whose timer expires before $ZTIMEOUT is read comes back 0 and has measured nothing.
	; That is a scheduling artifact rather than a failure: it only means the process took longer to
	; resume from the HANG than the margin between "initial" and "hangtime", which for scenario 2 is
	; 1.345 ms. Widening that margin is not an option, since the margin IS the value under test:
	; scenario 2 exists to show a remainder below 2 ms still carrying microsecond digits. So retry
	; such an attempt, and report a failure only if no attempt produced a reading.
	set maxtries=10
	for i=0:1:2  do
	. set out(i)=0
	. for try=1:1:maxtries  do measure  quit:0<out(i)
	set $ztimeout=-1	; Clear the timer so it doesn't expire before results are output

	; Output the value of $ZTIMEOUT for each scenario
	for i=0:1:2  do
	. if 0=out(i)  write "FAIL: $ztimeout=0 on every one of "_maxtries_" attempts at scenario "_i,!  quit
	. if out(i)'<(initial(i)-hangtime(i))  write "FAIL: $ztimeout="_out(i)_", but expected < "_(initial(i)-hangtime(i)),!  quit
	. write "$ZTIMEOUT="""_out(i)_"""",!

	quit
	;
measure	; One attempt at scenario "i". Leaves out(i) at 0 if the timer expired during the HANG.
	; The $ZTRAP set above goes to ^incrtrap, which resumes on the line AFTER the one that
	; erred, by line offset from the label. The line after "hang hangtime(i)" is the
	; "set out(i)=$ztimeout" that takes the measurement, and by then $ZTIMEOUT reads 0, so
	; the attempt yields 0 and the caller retries. Keep those three lines adjacent: a
	; comment inserted between the HANG and the SET becomes the resume line instead.
	;
	; The reading is stashed rather than written out here. Every WRITE in this routine
	; happens after "set $ztimeout=-1" has disarmed the timer, so no WRITE ever runs with a
	; timeout pending. That matters for the same reason: a trap taken part way through a
	; line holding a WRITE loses the rest of that line, including its ",!", and the output
	; of the following line then runs on to it. It is not that a SET may be interrupted and
	; a WRITE may not; it is that an interrupted SET costs only this measurement, which is
	; retried, while an interrupted WRITE would corrupt the output the outref is compared
	; against.
	set $ztimeout=initial(i)
	hang hangtime(i)
	set out(i)=$ztimeout
	quit
