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
;
; YDB#1281 : VIEW "STP_GCOL" must not expand the stringpool when nothing was allocated since the
; previous garbage collection.
;
; Each label below is run in its own process by stp_gcol_repeat-ydb1281.csh, so every stage starts
; from a new stringpool.
;
; The loops call VIEW "STP_GCOL" and nothing else. A FOR loop counter is a number and allocates no
; string, so no garbage is created between one garbage collection and the next.
;
ydb1281	;
	write "Run one label at a time. See stp_gcol_repeat-ydb1281.csh",!
	quit
	;
repeat	; VIEW "STP_GCOL" 12 times in a row, with the garbage collection mode given in $zcmdline
	new before,after,i
	view "STP_GCOL_NOSORT":+$zcmdline
	set before=$piece($view("SPSIZE"),",",1)
	for i=1:1:12 view "STP_GCOL"
	set after=$piece($view("SPSIZE"),",",1)
	do chk(after=before,"piece 1 of $VIEW(""SPSIZE"") (stringpool size) is the same after the 12 VIEW ""STP_GCOL"" as before them","before "_before_", after "_after)
	quit
	;
reclaim	; VIEW "STP_GCOL" still reclaims garbage
	new x,i,base,full,after
	view "STP_GCOL"
	set base=$piece($view("SPSIZE"),",",2)
	for i=1:1:20 set x=$justify(i,1000)
	set full=$piece($view("SPSIZE"),",",2)
	view "STP_GCOL"
	set after=$piece($view("SPSIZE"),",",2)
	do chk(full'<(base+20000),"piece 2 of $VIEW(""SPSIZE"") (bytes in use) grew by at least 20000 after 20 strings of 1000 bytes","base "_base_", after the strings "_full)
	do chk(after<(base+2048),"piece 2 of $VIEW(""SPSIZE"") is back within 2048 bytes of what it was before the strings","base "_base_", after VIEW ""STP_GCOL"" "_after)
	quit
	;
chk(ok,what,detail)
	; The actual values depend on the build and the environment, so they appear only when a check fails.
	write $select(ok:"PASS",1:"WRONG")," : ",what
	write:'ok " (",detail,")"
	write !
	quit
