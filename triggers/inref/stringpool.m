;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Routine to stress the stringpool inside and outside a trigger making sure garbage
; collection works correctly.
;
	For v=1:1:100 Do
	. Do GenSubs(.x,.y)
	. Set $ZTWormhole=v
	. Set ^a(v#10+1)=1		; Value overridden within trigger
	. Set ^b(v#10+1)=1		; .. ditto
	Do GenSubs(.x,.y)
	ZShow "V":zs
	View "STP_GCOL"			; One final GC before validation
	For v=1:1:10 Do
	. If (x(v)'=^a(v)) Do
	. . Write "x(",v,") not equal to ^a(",v,") - terminating",!
	. . ZShow "*"
	. . ZWrite ^a
	. . ZHalt 1
	. If (y(v)'=^b(v)) Do
	. . Write "y(",v,") not equal to ^b(",v,") - terminating",!
	. . ZShow "*"
	. . ZWrite ^b
	. . ZHalt 1
	Write "Passed",!
	Quit

;
; Create 2 arrays of strings
;
GenSubs(x,y)
	New i
	Kill x,y
	Set x="x",x(0)="",y="y",y(0)=""
	For i=1:1:10 Set x(i)=x(i-1)_x,y(i)=y(i-1)_y
	Quit

;
; Routine drive by trigger(s)
;
TrigProc(z)
	Set v=$ZTWormhole		; Iteration from caller
	Do GenSubs(.x,.y)		; Churn stringpool
	Set $ZTValue=z(v#10+1)		; Modify value that gets set (tiz either x or y)
	View "STP_GCOL"			; Drive garbage collection
	ZShow "V":zv			; More stringpool churn - all values disappear when trigger exits
	Quit
