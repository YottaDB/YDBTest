;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
othloc	; other lock
	zbreak othloc+2:"zstep into" set $zstep="set dollarh($incr(index),$zpos)=$h  zstep into"
	set maxtimeout=300	; seconds (same value is maintained in env_xlate/inref/locks.m)
	w "Step 1 (I should not be able to get the locks)...",!
	d test
	l ^othloc1	;step 1 finished
	w "step 1 finished",!
	f i=1:1:maxtimeout l +^locks2:0 Q:'$t  l -^locks2 h 1
	if (i=maxtimeout) w "Waited too long for locks to come to step 2. FAILED.",! zsh "*" q
	w "Step 2 (I should get the locks)...",!
	d test
	l +^othloc2	;step 2 finished
	w "step 2 finished",!
	w "waiting for ^locks to finish step 3 (he should not get the locks)",!
	f i=1:1:maxtimeout l +^locks3:0 Q:'$t  l -^locks3 h 1
	if (i=maxtimeout) w "Waited too long for locks to come to step 3. FAILED.",! zsh "*" q
	w "^othloc done.",!
	l +^othloc3
	h 2
	q

test	;
	w ".................TEST......................",!
	w "$ZGBLDIR: ",$ZGBLDIR,!
	w "ZSHOW:"
	zshow "L"
	w "-------------------",!
	w "l +^GBL1:5",!
	l +^GBL1:5
	w "$T=",$T,!
	w "l +LCL1:5",!
	l +LCL1:5
	w "$T=",$T,!
	zshow "L"
	w "L +^[""/a/b/c"",""sphere""]GBL1:5",!
	L +^["/a/b/c","sphere"]GBL1:5
	w "$T=",$T,!
	w "L +[""/a/b/c"",""sphere""]LCL1:5",!
	L +["/a/b/c","sphere"]LCL1:5
	w "$T=",$T,!
	zshow "L"
	w "..............END OF TEST..................",!
