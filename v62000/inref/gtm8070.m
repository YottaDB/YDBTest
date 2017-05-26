;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8070	; check Ben's proposed deadlock/livelock scenarios
	;
	new (act)						; define act before invocation to change default error action
	if '$data(act) new act set act="use $p write !,$zpos,! zprint @$zpos zshow ""v"" goto done"	;set up default error action
	new $etrap,$estack						; error handling initializatopn
	set $ecode="",$etrap="goto err",$zstatus="",zl=$zlevel
	set jmaxwait=0,jobid=1
	kill ^%jobwait
	do ^job("lock^"_$text(+0),1,"""""")
	for i=1:1:3600 hang .1 quit:""'=$get(^%jobwait(1,1))		; wait for pid of lock job
	if 3600=i,$increment(cnt) xecute act
	set stop=^%jobwait(1,1)				; pass it lock job pid to stop before job framework overlays it
	do ^job("stop^"_$text(+0),1,""""_stop_"""")
	set out="gtm8070.outtxt"
	open out:newver
	use out
	for i=1:1:3600 lock ^a:0 quit:'$test  lock -^a hang .1		; wait for lock to belong to lock job
	if 3600=i,$increment(cnt) xecute act
	for i=1:1:3600 lock ^stop:0 quit:'$test  lock -^stop hang .1	; wait for stop job to signal ready
	if 3600=i,$increment(cnt) xecute act
	set lockjob=^%jobwait(1,1),sigusr1=$ztrnlnm("sigusrval")
	kill i
	tstart ()
	hang:4=$trestart 1						; to control crit for a long time
	set ^TESTA=0
	write "TRESTART "_$trestart_" "_$increment(i),!
	lock +^a:1
	write:4=i "interrupt ",lockjob," ",$zsigproc(lockjob,sigusr1)
	if i<360&'$test trestart
	tcommit
	close out
done	write !,$select(i<360:"PASS",1:"FAIL")," from ",$text(+0)
	quit

err	set io=$io
	use $principal
	if $estack write:'$stack !,"error handling failed",$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	use io
	zgoto @next
	use $principal
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within error

lock	lock ^a
	hang 500							; be stupid greedy with the lock
	quit

stop(x) set $zinterrupt="zgoto -1:stopit"
	lock ^stop
	hang 360							; give main job a big chance to get to the forth retry
stopit	write ! zwrite x write ?10,$zsigproc(x,15)			; try mupip stop equivalent
	quit
