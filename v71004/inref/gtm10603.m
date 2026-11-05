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

gtm10603 ;
	quit

setprec	; SET $ZMAXTPTIME keeps millisecond precision
	do setone(".001",".001","whole seconds only")
	do setone(".333",".333","whole seconds only")
	do setone("59.999","59.999","whole seconds only")
	quit

setlimit	; SET $ZMAXTPTIME ignores values outside 0 to 60 seconds and keeps the previous value
	do setone(".5",".5","")
	do setone("61",".5","61")
	do setone("60.001",".5","")
	do setone("-1",".5","0")
	do setone("60","60","")
	quit

setone(val,expect,prev)
	set $zmaxtptime=val
	write "# SET $ZMAXTPTIME="_val_". Expect "_expect_"."_$select(""=prev:"",1:" Previously, "_prev_"."),!
	write "$ZMAXTPTIME="_$zmaxtptime,!
	quit

show	; Display the $ZMAXTPTIME the environment variable set at process startup
	write "$ZMAXTPTIME="_$zmaxtptime,!
	quit

timing	; Run a transaction that hangs for the second argument with $ZMAXTPTIME set to the first
	new hangtime,timeout
	set timeout=$piece($zcmdline," ",1),hangtime=$piece($zcmdline," ",2)
	set $etrap="write $select($zstatus[""TPTIMEOUT"":""TPTIMEOUT error"",1:$zstatus),! halt"
	set $zmaxtptime=timeout
	tstart ():serial
	set ^x=hangtime
	hang hangtime
	tcommit
	write "Transaction committed",!
	quit
