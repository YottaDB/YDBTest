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
;
; Routine to test GTM-7811 where a MUPIP STOP interrupt is recognized in tp_unwind() during
; a TP restart unwind of the trigger frame. GT.M V60002 and earlier releases have this problem
; which shows up as a sig-11/accvio because dollar_tlevel was not corrected prior to allowing interrupts
; in which caused there to be fewer entries on the TP stack than dollar_tlevel indicated. It
; shows up as a sig-11. Note this is a white-box test so should only run in debug mode.
;
	Kill ^a,^b
	Set (a,b,c)=42
	TStart (a,b,c)
	Set ^a(1)=$Justify(1,50)		; Create a few global vars which drive our trigger that explodes.
	;
	; Should never get here
	;
	TCommit
	Write "Fail - test run did not terminate like it should have",!!
	Quit

