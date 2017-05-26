;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tcommitdisallow	;
	set $etrap="do etr^tcommitdisallow"
	set dispstr="---------------------------"
	write dispstr,!
	set label="test"_$zcmdline
	set ^label=label
	write "Testcase ",label,!
	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $zstatus=",$zstatus,!
	do ^sstep
	do @label
	quit
test1	;
	write "Non-TP sets that are implicitly converted to TP",!
	set ^f(1)=1
	quit
test2	;
	write "TP sets where Tstart is at same $zlevel as erroring set",!
	tstart ():serial
	set ^f(2)=2
	quit
test3	;
	write "TP sets where Tstart is at different $zlevel than erroring set (for loop)",!
	tstart ():serial
	for i=1:1:1  set ^f(3)=3
	quit
test4	;
	write "TP sets where Tstart is at different $zlevel than erroring set (dotted do)",!
	tstart ():serial
	do
	.	set ^f(4)=4
	quit
test5	;
	write "Do nested TSTART/TCOMMIT after unhandled error in trigger context; Outer TCOMMIT should still fail",!
	tstart ():serial
	do
	.	set ^f(55)=55
	quit
test6	;
	write "Do INCREMENTAL TROLLBACK of unhandled error in nested TSTART; Outer TCOMMIT should succeed",!
	set ^startztlevel=$ztlevel
	tstart ():serial
	do
	.	set ^good=$get(^good)+1
	.	tstart ():serial
	.	set ^f(6)=6
	quit
test7	;
	write "Do test6 but inside triggerland (i.e. where $tlevel=0 and $ztlevel>0) and $ecode is NULL",!
	set $etrap="do etrcommon^tcommitdisallow(""test6"")"
	set ^ecodenull=1
	set ^f(7)=7
	quit
test8	;
	write "Do test6 but inside triggerland (i.e. where $tlevel=0 and $ztlevel>0) and $ecode is non-NULL",!
	set $etrap="do etrcommon^tcommitdisallow(""test6"")"
	set ^ecodenull=0
	set ^f(8)=8
	quit
test9	;
	write "Do test5 but inside triggerland (i.e. where $tlevel=0 and $ztlevel>0) and $ecode is NULL",!
	set $etrap="do etrcommon^tcommitdisallow(""test5"")"
	set ^ecodenull=1
	set ^f(9)=9
	quit
test10  ;
	write "Do test5 but inside triggerland (i.e. where $tlevel=0 and $ztlevel>0) and $ecode is non-NULL",!
	set $etrap="do etrcommon^tcommitdisallow(""test5"")"
	set ^ecodenull=0
	set ^f(10)=10
	quit
etrcommon(tst);
	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $tlevel=",$tlevel," : $zstatus=",$zstatus,!
	if $tlevel  trollback
	set $etrap="do etr^tcommitdisallow"
	set ^label=tst
	set label=^label
	if ^ecodenull  set $ecode=""
	if $ztlevel  do
	.	do @tst
	quit
etr	;
	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $tlevel=",$tlevel," : $zstatus=",$zstatus,!
	if $get(label)="test5" do
	.	tstart ():serial
	.	set ^good=$get(^good)+1
	.	tcommit
	if $get(^label)="test6" quit:$ztlevel>^startztlevel  do
	.	if $ztlevel=^startztlevel  do
	.	.	if $tlevel>1 do
	.	.	.	trollback 1	; do incremental trollback
	if $zlevel>2  do
	.	if $tlevel  do
	.	.	tcommit
	if $tlevel  do
	.	trollback
	; print globals just before exiting to make sure we updated them as expected
	if $data(^f) zwrite ^f
	if $data(^good) zwrite ^good
	set $ecode=""
	quit

setup
	do ^echoline
	write "Testing of TCOMMITDISALLOW error",!
	write "The uncommitable transaction (TCOMMITDISALLOW error) issue occurs only when a trigger frame is forcibly unwound",!
	write "(because of an error) causing an abnormal transition from triggerland to non-trigger-land (i.e. M-land). In the",!
	write "case of a non-TP explicit update, if the error gets rethrown in the triggering M-frame (after the transition from",!
	write "triggerland to non-trigger-land), as part of error_return(), we will repoint the frame_pointer->mpc to error_return",!
	write "and unwind the M-stack including the op_tstart that was done (by an explicit OP_TROLLBACK) so we can never have",!
	write "this issue because of a non-TP explcit update.",!
	do item^dollarztrigger("tfile^tcommitdisallow","tcommitdisallow.trg.trigout")
	quit

tfile
	;+^f(subs=:4;6:) -command=S -xecute="xecute ""$ZTRIGgerop ^e(""_subs_"")"""
