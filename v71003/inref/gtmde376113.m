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
	hang 10
	write !
	write "# Verify the number of times $ZTIMEOUT executed (ztimeoutcnt).",!
	write "# This is to ensure that $ZTIMEOUT executed at least 700 times, i.e. within 70 percent of the 1000 times expected.",!
	set prefix=$select((ztimeoutcnt>=700):"PASS",1:"FAIL")
	write prefix_": ztimeoutcnt="_ztimeoutcnt,!
	quit

ztim ;
	if $increment(ztimeoutcnt)
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
