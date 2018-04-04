;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2002, 2014 Fidelity Information Services, Inc	;
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
; Test $ETRAP/$ZTRAP interaction
;
tstetzt	;
	; When $ZT in use, call to rtn does New and set of $ET
	;
	S $ZT="do whatever1"
	d B
	if $ZT'="do whatever1" Do
	. W "$ZT did not come back unscathed. New value is: ",$ZT,!
	E  W "Pass",!

tstetzt2	;
	; When $ZT in use and called rtn resets $ZT without newing, that
	; should be the value when we come back too
	;
	S $ZT="do whatever2"
	d B2
	if $ZT'="do whatever4" Do
	. W "$ZT came back unscathed. New value is: ",$ZT," and $ET is: ",$et,!
	if $ET'="" Do
	. W "$ET did not come back nil. $ZT is: ",$ZT," and $ET is: ",$et,!
	E  W "Pass",!

tstetzt3	;
	; If $ZT in use and call routine that sets $ET without newing it, then
	; unwinding that frame should restore $ZT and clear $ET.
	;
	S $ZT="do whatever3"
	d B3
	if $ZT'="do whatever3" Do
	. W "$ZT did not come back unscathed. New value is: ",$ZT,!
	E  W "Pass",!
	Q

B	New $ZT
	New $ET; S $ET="do whatever4"
	Q

B2	S $ZT="do whatever4"
	Q

B3	New $ZT
	S $ET="do whatever5"
	Q
