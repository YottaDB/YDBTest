;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm10603 ;
	set timeout=$piece($zcmdline," ",1)
	set operation=$piece($zcmdline," ",2)
	set modifier=$piece($zcmdline," ",3)
	; Set the timeout or $ZMAXTPTIME based on the test case
	if "env"=timeout  do
	. ; The timeout is set by gtm_zmaxtptime, so set the timeout accordingly
	. set timeout=$ZTRNLNM("gtm_zmaxtptime")
	else  do
	. ; The timeout is set by an argument to this routine, so set the $ZMAXTPTIME accordingly
	. set $zmaxtptime=timeout
	; Set the time to hang in the transaction based on the test case, either more or less than the timeout
	set:"plus"=operation hangtime=+timeout+modifier
	set:"minus"=operation hangtime=+timeout-modifier
	do trans^gtm10603(hangtime,operation,timeout)
	quit

trans(hangtime,modifier,timeout)
	set $etrap="write !,$zstatus,! halt"
	set expectTimeout=("plus"=operation)&(timeout<=60)
	tstart ():serial
	if 3>$trestart trestart

	write "# Hang for "_hangtime_" seconds. "
	write:expectTimeout "Expect TPTIMEOUT error."
	write:'expectTimeout "Expect transaction to complete without TPTIMEOUT error.",!

	hang hangtime

	write:expectTimeout "FAIL: "
	write:'expectTimeout "PASS: "
	write "Transaction did not timeout.",!
	tcommit:$tlevel
	quit
