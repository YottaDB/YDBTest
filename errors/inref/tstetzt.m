;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test $ETRAP/$ZTRAP interaction
;
tstetzt	;
	; When $ZT in use, call to rtn does New and set of $ET
	;
	S $ZT="whatever"
	d B
	if $ZT'="whatever" Do
	. W "$ZT did not come back unscathed. New value is: ",$ZT,!
	E  W "Pass",!

tstetzt2	;
	; When $ZT in use and called rtn resets $ZT without newing, that
	; should be the value when we come back too
	;
	S $ZT="whatever"
	d B2
	if $ZT'="Something else" Do
	. W "$ZT came back unscathed. New value is: ",$ZT," and $ET is: ",$et,!
	if $ET'="" Do
	. W "$ET did not come back nil. $ZT is: ",$ZT," and $ET is: ",$et,!
	E  W "Pass",!

tstetzt3	;
	; If $ZT in use and call routine that sets $ET without newing it, then
	; unwinding that frame should restore $ZT and clear $ET.
	;
	S $ZT="whatever"
	d B3
	if $ZT'="whatever" Do
	. W "$ZT did not come back unscathed. New value is: ",$ZT,!
	E  W "Pass",!
	Q

B	New $ZT
	New $ET; S $ET="this is something"
	Q

B2	S $ZT="Something else"
	Q

B3	New $ZT
	S $ET="this is something"
	Q
