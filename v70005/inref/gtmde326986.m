;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde326986	;
	write "; Start 8 child jobs to attach to AREG region while MUPIP INTEG -ONLINE is concurrently running",!
	set jmaxwait=0,^stop=0,^shmidfound=0
	write "; Induce a random sleep in child before update to AREG (using ^a global) in child^gtmde3269786 to",!
	write "; ensure more chances of a job's update to AREG happening while a MUPIP INTEG -ONLINE is in progress",!
	do ^job("child^gtmde326986",8,"""""")
	quit
child	;
	hang $random(1000)*0.01
	set ^a($job)=$job
	for  quit:$get(^stop)=1  hang 1	; Wait for signal from parent script to halt
	quit

