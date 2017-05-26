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
gtm7843	; generates activity then causes an instance freeze so the test can check whether it caused a MUTEXLCKALERT procstuckexec
	; This test contains nothing UNIX specific but is in inref_u because the feature it's testing is UNIX specific
	; We need to cause some crit conflicts - create contention by jobbing off processes that do concurrent updates.
	new (act,debug)
	if '$data(act) new act set act="use $principal write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	set numjobs=100
	kill ^x
	set ^stop=0
	set jmaxwait=0
	do ^job("activity^"_$text(+0),numjobs,"""""")
	for i=1:1:100 quit:(numjobs/2)<$get(^active)  hang 1	; wait until a fair number of processes have started
	; Freeze the instance and wait past the time it takes to recognize and issue a MUTEXLOCKALERT message.
	; We expect MUTEXLCKALERT to be suppressed because of the Instance Freeze.
	; However, there's a chance we'll get one as it's cleared - see the driver shell script for how it deals with that.
	; Do freeze/sleep/unfreeze cycle in one shot to prevent ourselves from freezing should we get tagged for a disk write.
	zsystem "$MUPIP replic -source -freeze=on -comment=FROZEN; sleep 70; $MUPIP replic -source -freeze=off"
	set ^stop=1
	do wait^job	; wait for children to terminate
	quit
activity;
	set act="write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack,i
	set $ecode="",$etrap="goto err",zl=$zlevel
	if $increment(^active)
	for i=1:1 quit:^stop=1  set ^x($job,$justify(i,50))=$justify(i,800)
	quit
err	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zlevel_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	set ^stop=1
	zhalt 4	; in case of error within err
