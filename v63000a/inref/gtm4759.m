;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm4759
	set defgld="alt.gld"
	for i=1:1:7 do
	.	set gld=$select(3<i:"rm.gld",1:defgld)
	.	zsystem "if !(-e rm.gld) ln mumps.gld rm.gld"
	.	set cmd="test"_i_"^gtm4759:(OUTPUT=""test"_i_".mjo"":ERROR=""test"_i_".mjo"":GBLDIR="""_gld_""")"
	.	job @(cmd)
	.	set waitlist($zjob)=1
	.	do ^waitforproctodie($zjob,10)  ; Cannot use locks here because we are fuzzing the global directory settings
	set i=""
	for  set i=$order(waitlist(i)) quit:""=i  do ^waitforproctodie(i,30)
	quit
; After you NEW $zgbldir, you should always get the prior value from the stack
test1
	write !,"Testing retention of starting zgbldir regardless of validity",!
	set before=$zgbldir
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	do
	.	new $zgbldir
	.	set $zgbldir=gtmhelp
	.	set x=$data(^nosuchgbl)
	if (before=$zgbldir)&(0=x) write "TEST-I-PASS",!
	else  zwrite x,before,$zgbldir
	set $zgbldir="mumps.gld",^done($job)=1
	quit
; If you change $zgbldir and then NEW it in another stack level, the NEW'ed value should be what's in
; $gtmgbldir and once you unstack, you should get the old value back
test2
	write !,"Testing retention of zgbldir set during execution of routine",!
	set $ETRAP="write ""TEST-F-FAIL"",! zwrite $zstatus zwrite  halt"
	set before=$zgbldir
	set zgbldir="mumps.gld",$zgbldir=zgbldir
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	do
	.	new $zgbldir
	.	set in=$zgbldir
	.	set $zgbldir=gtmhelp
	.	set x=$data(^nosuchgbl2)
	if (zgbldir=$zgbldir)&(before'=$zgbldir)&(before=in)&(0=x) write "TEST-I-PASS",!
	else  zwrite x,before,in,$zgbldir
	set ^done($job)=1
	quit
; External references should not error out if $zgbldir isn't valid
test3
	write !,"Testing retention of glbdir after ext ref",!
	set $ETRAP="write ""TEST-F-FAIL"",! zwrite $zstatus zwrite  halt"
	set before=$zgbldir
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	set x=$data(^|gtmhelp|nosuchgbl3)
	if (before=$zgbldir)&(0=x) write "TEST-I-PASS",!
	set $zgbldir="mumps.gld",^done($job)=1
	quit
; If you define a valid GLD, up stack frame, NEW $zgbldir, down stack frame, and try to use it, it won't work
test4
	write !,"Testing if gld was not loaded, we cannot use it later",!
	set $ETRAP="write:$zstatus[""ZGBLDIRACC"" ""TEST-I-PASS"",! halt"
	set before=$zgbldir
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	set rm="rm -f "_before
	do
	.	new $zgbldir
	.	set in=$zgbldir
	.	set $zgbldir=gtmhelp
	.	set x=$data(^nosuchblg4)
	.	zsystem rm
	set ^a=1
	write "TEST-F-FAIL",!
	set $zgbldir="mumps.gld",^done($job)=1
	quit
; If you define a valid GLD, use it, up stack frame, NEW $zgbldir, down stack frame, and use it again without problems
test5
	write !,"Test once gld is loaded, we can still use it even after it was deleted",!
	set $ETRAP="write ""TEST-F-FAIL"",! zwrite $zstatus zwrite  halt"
	set before=$zgbldir
	set gtmgbldir=$ztrnlnm("gtmgbldir")
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	set rm="rm -f "_before
	do
	.	set ^a=99
	.	new $zgbldir
	.	set in=$zgbldir
	.	set $zgbldir=gtmhelp
	.	set x=$data(^nosuchgbl5)
	.	zsystem rm
	kill ^a
	write "TEST-I-PASS",!
	set $zgbldir="mumps.gld",^done($job)=1
	quit
; As documented, setting $zgbldir causes GT.M to load $gtmgbldir into $zgbldir
test6
	write !,"Test that nullifying $zgbldir restores it to $gtmgbldir",!
	set $ETRAP="write ""TEST-F-FAIL"",! zwrite $zstatus zwrite  halt"
	set before=$zgbldir
	set gtmhelp=$ztrnlnm("gtm_dist")_"/gtmhelp.gld"
	set $zgbldir=gtmhelp
	set $zgbldir=""
	if before=$zgbldir write "TEST-I-PASS",! quit
	write "TEST-F-FAIL",! zwrite before,$zgbldir
	quit
; If you define a valid GLD, use it, up stack frame, NEW $zgbldir + change directory, down stack frame,
; and use it again without problems
test7
	write !,"Test once gld is loaded, we can still use it even after it was deleted and directory changed",!
	set $ETRAP="write ""TEST-F-FAIL"",! zwrite $zstatus zwrite  halt"
	set zdir=$zdir
	set before=$zgbldir
	set gtmgbldir=$ztrnlnm("gtmgbldir")
	set gtmhelp="$gtm_dist/gtmhelp.gld"
	set rm="rm -f "_before
	do
	.	set ^a=101
	.	set $zdir="/tmp/"
	.	new $zgbldir
	.	set in=$zgbldir
	.	set $zgbldir=gtmhelp
	.	set x=$data(^nosuchgbl5)
	.	zsystem rm
	kill ^a
	write "TEST-I-PASS",!
	set $zgbldir=zdir_"mumps.gld",^done($job)=1
	quit
