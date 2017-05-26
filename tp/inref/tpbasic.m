;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TPBASIC	; ; ; basic test of transactions
	;
	n (act)
	i '$d(act) n act s act="w !,""FAIL in "",LAB"
	s ITEM="Transaction Commit",ERR=0
	k ^a
	; Spawn off 2 jobs concurrently updating the same global inside of TP
	do ^job("thread^tpbasic",2,"""""")
	;
	do EXAM(ITEM,^a,1024)
	w !,$s(ERR:"FAIL",1:"PASS")," from ",$t(+0)
	q

thread	;
	do ACC(jobindex-1)
	quit

ACC(p)
	view "GDSCERT":1
	s ^a(p)=p
	s tp0=$zgetjpi(0,"CPUTIM")
	TSTART ():serial
	f k=0:1:511  s ^a=$g(^a)+1
	TCOMMIT
	s tp1=$zgetjpi(0,"CPUTIM")
	w "timing with TP : ",tp1-tp0,!
	w ^a,!

	; the following code compares the performance using a single lock
	s t0=$zgetjpi(0,"CPUTIM")
	l +^b
	f k=0:1:511  s ^b=$g(^b)+1
	s t1=$zgetjpi(0,"CPUTIM")
	w "timing without TP, without a lock on every increment : ",t1-t0,!
	l -^b

	; the following code compares the performance using a lock every time
	s t0=$zgetjpi(0,"CPUTIM")
	f k=0:1:511  l +^b  s ^b=$g(^b)+1  l -^b
	s t1=$zgetjpi(0,"CPUTIM")
	w "timing without TP, with a lock on every increment : ",t1-t0,!
	l
	q

EXAM(LAB,VCOMP,VCORR)
	i VCOMP=VCORR q
	s ERR=ERR+1
	W !,"Fail at ",LAB,!
	w ?10,"COMPUTED = ",VCOMP,!
	w ?10,"CORRECT  = ",VCORR,!
	x act
	q
