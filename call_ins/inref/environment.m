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
; Routine to exercise $VIEW("ENVIRONMENT") in various situations.
;
environment
	;
	; First just run it in open runtime code - should give "MUMPS"
	;
	write "Return value from $VIEW(""ENVIRONMENT"") in runtime code: ",$view("ENVIRONMENT"),!
	;
	; Need to test in a callin so drive a call-out first to a call-in to the environci entry point below
	;
	write !,"Driving external call/callin to check value in that environment (follows):",!
	set cirtnname="environci"
	do &drivecirtn(.cirtnname)
	;
	; Now update a global which will fire a trigger both on the primary and secondary doing the
	; same thing.
	;
	write !,"Driving trigger to show $VIEW(""ENVIRONMENT"") - value there follows:",!
	set ^A=42
	quit

;
; Entry point drive by call-in (after call-out) to drive $VIEW("ENVIRONMENT") in that situation
;
environci
	write !,"Return value from $VIEW(""ENVIRONMENT"") in call-in mode: ",$view("ENVIRONMENT"),!
	;
	; We're in a call-in - let's drive a trigger too
	;
	write !,"Driving trigger to show $VIEW(""ENVIRONMENT"") from inside a CALL-IN - value there follows:",!
	set ^A=41
	quit
