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
; Helper routines of the epochtaper_loneupdater-gtm10623 subtest. See that subtest for the overall scheme.
gtm10623	;
	quit

updater	; Do updates with no pause in between until ^stop is set
	new i
	set ^pid($job)=1
	for i=1:1  quit:$data(^stop)  set ^a($job,i#5000)=$justify(i,200)
	quit

sample	; Sample two fields of the shared memory of region DEFAULT every 0.05 seconds for "seconds" ($ZCMDLINE) seconds :
	; epoch_taper_start_dbuffs is not zero only while a process is tapering, and epoch_taper_last_pid is the
	; process that last ran the epoch tapering code. This process only looks at shared memory. This process
	; does not read or update any global until the end, and so does not run the epoch tapering code.
	new seconds,i,dbuffs,lastpid,tapered,pids,pid,count,start
	set seconds=+$zcmdline,tapered=0
	set start=$zut
	for i=1:1  quit:($zut-start)>(seconds*1000000)  do
	. set dbuffs=$$^%PEEKBYNAME("node_local.epoch_taper_start_dbuffs","DEFAULT")
	. set lastpid=$$lastpid
	. if dbuffs set tapered=tapered+1
	. if lastpid set pids(lastpid)=1
	. hang 0.05
	set ^stop=1
	write "Number of samples with a non-zero epoch_taper_start_dbuffs : ",$select(tapered:"more than zero",1:"zero"),!
	set count=0,pid=""
	for  set pid=$order(pids(pid)) quit:pid=""  set count=count+1  if '$data(^pid(pid)) write "FAIL : epoch_taper_last_pid ",pid," is not an updater",!
	write "Number of updater processes seen in epoch_taper_last_pid : ",count,!
	quit

lastpid()	; return the epoch_taper_last_pid field, or 0 if the field does not exist (releases before V7.1-004)
	new $etrap
	set $etrap="set $ecode="""" quit 0"
	quit $$^%PEEKBYNAME("node_local.epoch_taper_last_pid","DEFAULT")
