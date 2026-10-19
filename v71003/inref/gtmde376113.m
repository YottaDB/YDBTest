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

gtmde376113 ;
	kill ^x
	set ^x=$j
	write "# Set $ZTIMEOUT to periodically print a digit every 0.01 seconds",!
	set $ZTIMEOUT="0.01:do ztim"
	write "# Set $ZINTERRUPT to do nothing when this process receives a signal, i.e. SIGUSR1 from kill^gtmde376113.",!
	set $ZINTERRUPT=""
	write "# Spawn a job to periodically send SIGUSR1 to this process",!
	job kill^gtmde376113
	write "# Hang for 10 seconds while $ZTIMEOUT executes every 0.01 seconds and SIGUSR1 is sent by kill^gtmde376113:",!
	set start=$zut
	hang 10
	write !
	write "# Verify that the LAST $ZTIMEOUT fired in the final part of the 10 second window.",!
	write "# The defect stops $ZTIMEOUT part way through the window, so the offset of the last one separates the two",!
	write "# behaviours whatever the machine's load, where a count of the timeouts does not: the vector re-arms",!
	write "# $ZTIMEOUT itself, so the achievable count is 10 seconds divided by 0.01 plus the per-iteration overhead,",!
	write "# and a loaded machine drops it below any fixed floor.",!
	; $ZUT is microseconds. ztlast is undefined if $ZTIMEOUT never fired at all, which must also fail.
	set lastoff=$select($data(ztlast):(ztlast-start)/1000000,1:-1)
	if lastoff>8 write "PASS: $ZTIMEOUT kept firing to the end of the window",!
	else  write "FAIL: the last $ZTIMEOUT fired "_lastoff_" seconds into the 10 second window, ztimeoutcnt="_$get(ztimeoutcnt,0),!
	quit

ztim ;
	if $increment(ztimeoutcnt)
	set ztlast=$zut
	; Set $ZTIMEOUT to call this label again in 0.01 seconds
	set $ztimeout="0.01:do ztim"
	quit

kill ;
	set pid=^x
	write "# Loop, periodically sending SIGUSR1 to the parent gtmde376113 process at a random interval until it terminates",!
	for i=1:1 do  quit:'$zgetjpi(pid,"ISPROCALIVE")
	. if $zsigproc(pid,10)
	. hang $random(10)*0.01
	quit
