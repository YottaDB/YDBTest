;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7836	;
	; Sorts-after operator should correctly interpret undefined data in recycled lv slots.
	;
	View "NOUNDEF"
	For i=1:1:2 Do
	.	Set x(1)=1	; create a new lv slot, with uninitialized str.len field
	.	Kill x		; return slot to free queue
	.	New y		; reuse freed slot (happens on second loop iteration)
	.	Set %=25805]]y	; 25805 is just an arbitrary number
	.	If %'=1 ZWRite %,i Write "!!! incorrect result: % not equal to 1",! Halt
	Write "DONE!",!
	Quit
