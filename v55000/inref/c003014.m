;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test fix for TR C9I08-003014 - CTRAP(3) error causing stack unwind to fail
;
	;
	; Set up special $ETRAP that will get rethrown a bunch of times
	;
	Set $ETrap="Set:'$Data(OK) OK=$ZStatus[""CTRAP"",ZL=$ZLevel Set:(2=$ZLevel) $ECode="""" Write:($ZLevel=ZL)&'OK $ZJOBEXAM()"
	;
	; Create a series of calls on the stack
	;
	Do ep1^c003014A()
	Write !,$Select(OK:"PASS",1:"FAIL")," from ",$Text(+0),!
	Quit

ep2()
	Do ep2^c003014A()
	Quit

;
; In this frame, create an indirect frame - The issue (if it occurs) happens when this indirect frame has its 
; mpc/ctxt overwritten when the error is rethrown here causing all sorts of problems..
;
ep3()
	New X
	Set X="ep3^c003014A(.a,.b)"
	Do @X
	Quit

ep4()
	Do ep4^c003014A()
	Write !,"FAIL from ",$Text(+0),!
	Halt
