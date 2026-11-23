;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper routines of the dmode_intrpt_stackleak-gtm9815 subtest. See that subtest for the overall scheme.
gtm9815	;
	quit

intrpt	; Send SIGUSR1 (what MUPIP INTRPT sends) "count" times to process "pid", which is at the Direct Mode prompt.
	; The $ZINTERRUPT code of that process increments ^cnt. Wait for each increment before sending the next
	; signal so that every signal runs the $ZINTERRUPT code (signals sent too close together are merged).
	new pid,count,i,j,ok
	set pid=$piece($zcmdline," ",1),count=$piece($zcmdline," ",2)
	set ok=1
	for i=1:1:count  do  quit:'ok
	. if $zsigproc(pid,"SIGUSR1") set ok=0 write "TEST-E-FAIL : could not send SIGUSR1 number ",i,!  quit
	. for j=1:1:30000  quit:$get(^cnt)=i  hang 0.001
	. if $get(^cnt)'=i set ok=0 write "TEST-E-FAIL : $ZINTERRUPT code did not run for SIGUSR1 number ",i,!
	quit
