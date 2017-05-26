;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
locks	; test extended ref. locks
	zbreak locks+2:"zstep into" set $zstep="set dollarh($incr(index),$zpos)=$h  zstep into"
	set maxtimeout=300	; seconds (same value is maintained in env_xlate/inref/othloc.m)
	w "--LOCKS TESTING--",!
	w "$ZGBLDIR is: ",$ZGBLDIR,!
	;s $ZTRAP="goto err"
	Set unix=$ZVersion'["VMS"
	set jobu="^othloc:(output=""othloc.mjo"":error=""othloc.mje"")"
	set jobv="^othloc:(nodetached:startup=""startup.com"":output=""othloc.mjo"":error=""othloc.mje"")"
	d test1
	 w "Now start ^othloc...",!
	 If unix Job @jobu
	 Else  Job @jobv
	 w "Waiting for ^othloc to finish step 1...",!
	 for i=1:1:maxtimeout l +^othloc1:0 Q:'$T  l -^othloc1 h 1
	 if (i=maxtimeout) w "Waited too long for othloc to come to step 1. FAILED",! zsh "*" q
	 w "^othloc finished step 1.",!
	d test2
	 w "Released locks, waiting for ^othloc to finish step 2...",!
	 l +^locks2
	 for i=1:1:maxtimeout l +^othloc2:0 Q:'$T  l -^othloc2 h 1
	 if (i=maxtimeout) w "Waited too long for othloc to come to step 2. FAILED",! zsh "*" q
	d test1
	 l +^locks3
	 for i=1:1:maxtimeout l +^othloc3:0 Q:'$T  l -^othloc3 h 1
	 if (i=maxtimeout) w "Waited too long for othloc to come to step 3. FAILED",! zsh "*" q
	h 2
	w "--LOCKS TESTING END--",!
	q

test1	;
	w ".................TEST1.....................",!
	w "L +^[""/a/b/c"",""beowulf""]GBL1:5",!
	L +^["/a/b/c","beowulf"]GBL1:5
	w "$T=",$T,!
	w "L +[""/a/b/c"",""beowulf""]LCL1:5",!
	L +["/a/b/c","beowulf"]LCL1:5
	w "$T=",$T,!
	w "ZSHOW ""L"":",!
	zshow "L"
	d lkes
	w "...........................................",!
	w "L +^GBL1:5",!
	L +^GBL1:5
	w "$T:",$T,!
	w "L +LCL1:5",!
	L +LCL1:5
	w "$T:",$T,!
	w "ZSHOW should distinguish!!!!",!
	w "ZSHOW ""L"":",!
	zshow "L"
	d lkes
	w "..............END OF TEST1.................",!
	q
test2	;
	w ".................TEST2.....................",!
	w "l",!
	l
	w "ZSHOW ""L"":",!
	zshow "L"
	w "..............END OF TEST2.................",!
	q

err	;
	w "#####ERROR###########################",!,$zstatus,!,"#####################################",!
	zgoto $zL
	w "continue...",!
	q
lkes	; use lke to check lock status
	w "Check with LKE...",!
	w "--------------",!
	;if unix  d
	d
	. zsystem "echo $gtmgbldir; $LKE show -all"
	. w "--------------",!
	. zsystem "setenv gtmgbldir a.gld; echo $gtmgbldir; $LKE show -all"
	w "--------------",!
	w "..done with lke...",!
