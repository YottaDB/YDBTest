;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; This is a copy of booltest.m from https://gitlab.com/YottaDB/DB/YDB/-/issues/546#note_299129926
; This is driven by test9 label in r134/inref/ydb546.m.
;
booltest;
	set $etrap="zwrite $ZSTATUS  halt"
	new i,depth,boolexpr,xstr,failcnt,value,expect,boolrslt,result
	set value(0)=0,value(1)=1
	set false=0,true=1,expect(0)=0,expect(1)=1,failcnt=0
	set starttime=$horolog,elapsedtime=0,maxwait=1+$random(15)
	for i=1:1 do  quit:(maxwait<elapsedtime)
	. for boolrslt=0,1 do
	. . set depth=8
	. . set dlrtest=$random(2)	; construct boolexpr assuming $test=dlrtest
	. . set boolexpr=$select(boolrslt=0:$$zero(depth),boolrslt=1:$$one(depth))
	. . set result=0,xstr="set:"_boolexpr_" result=1"
	. . if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. . xecute xstr
	. . if ((value(boolrslt)'=1)&result) do
	. . . write "FAIL from postconditionaltest : dlrtest=",dlrtest
	. . . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to TRUE",!
	. . . if $increment(failcnt)
	. . if ((value(boolrslt)=1)&'result) do
	. . . write "FAIL from postconditionaltest : dlrtest=",dlrtest
	. . . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to FALSE",!
	. . . if $increment(failcnt)
	. if i#10=0 set elapsedtime=$$^difftime($horolog,starttime)
	if '$get(failcnt)  write "PASS from ydb546booltest (command postconditional test)",!
	;
	quit

zero(depth)	; Returns a random boolean expression that is guaranteed to evaluate to 0
	new rand,depth1,depth2,ret
	if depth=0 do  quit ret
	. set rand=$random(4)
	. if rand=0 set ret="0"
	. if rand=1 set ret="('true)"
	. if rand=2 set ret="false"
	. if rand=3 set ret=$select(dlrtest:"'$test",1:"$test")
	set depth1=$random(depth),depth2=$random(depth)
	set rand=$random(33)
	if rand=0 quit "("_$$one(depth1)_"="_$$zero(depth2)_")"
	if rand=1 quit "("_$$zero(depth1)_"="_$$one(depth2)_")"
	if rand=2 quit "("_$$zero(depth1)_"'="_$$zero(depth2)_")"
	if rand=3 quit "("_$$one(depth1)_"'="_$$one(depth2)_")"
	if rand=4 quit "("_$$zero(depth1)_">"_$$one(depth2)_")"
	if rand=5 quit "("_$$one(depth1)_"<"_$$zero(depth2)_")"
	if rand=6 quit "("_$$zero(depth1)_"'<"_$$one(depth2)_")"
	if rand=7 quit "("_$$one(depth1)_"'>"_$$zero(depth2)_")"
	if rand=8 quit "("_$$zero(depth1)_">="_$$one(depth2)_")"
	if rand=9 quit "("_$$one(depth1)_"<="_$$zero(depth2)_")"
	if rand=10 quit "("_$$one(depth1)_"["_$$zero(depth2)_")"
	if rand=11 quit "("_$$zero(depth1)_"["_$$one(depth2)_")"
	if rand=12 quit "("_$$zero(depth1)_"]"_$$one(depth2)_")"
	if rand=13 quit "("_$$zero(depth1)_"]]"_$$one(depth2)_")"
	if rand=14 quit "("_$$one(depth1)_"'["_$$one(depth2)_")"
	if rand=15 quit "("_$$zero(depth1)_"'["_$$zero(depth2)_")"
	if rand=16 quit "("_$$one(depth1)_"']"_$$zero(depth2)_")"
	if rand=17 quit "("_$$one(depth1)_"']]"_$$zero(depth2)_")"
	if rand=18 quit "("_$$one(depth1)_"?1""0"""_")"
	if rand=19 quit "("_$$zero(depth1)_"?1""1"""_")"
	if rand=20 quit "("_$$one(depth1)_"'?1""1"""_")"
	if rand=21 quit "("_$$zero(depth1)_"'?1""0"""_")"
	if rand=22 quit "("_"'"_$$one(depth1)_")"
	if rand=23 quit "("_$$zero(depth1)_"&"_$$zero(depth2)_")"
	if rand=24 quit "("_$$one(depth1)_"&"_$$zero(depth2)_")"
	if rand=25 quit "("_$$zero(depth1)_"&"_$$one(depth2)_")"
	if rand=26 quit "("_$$one(depth1)_"'&"_$$one(depth2)_")"
	if rand=27 quit "("_$$zero(depth1)_"!"_$$zero(depth2)_")"
	if rand=28 quit "("_$$zero(depth1)_"'!"_$$one(depth2)_")"
	if rand=29 quit "("_$$one(depth1)_"'!"_$$zero(depth2)_")"
	if rand=30 quit "("_$$one(depth1)_"'!"_$$one(depth2)_")"
	if rand=31 quit "('"_$$one(depth1)_")"
	if rand=32 quit $$selecthelper(0,depth1,depth2)
	quit

one(depth)	; Returns a random boolean expression that is guaranteed to evaluate to 1
	new rand,depth1,depth2
	if depth=0 do  quit ret
	. set rand=$random(4)
	. if rand=0 set ret="1"
	. if rand=1 set ret="('false)"
	. if rand=2 set ret="true"
	. if rand=3 set ret=$select(dlrtest:"$test",1:"'$test")
	set depth1=$random(depth),depth2=$random(depth)
	set rand=$random(33)
	if rand=0 quit "("_$$zero(depth1)_"="_$$zero(depth2)_")"
	if rand=1 quit "("_$$one(depth1)_"="_$$one(depth2)_")"
	if rand=2 quit "("_$$one(depth1)_"'="_$$zero(depth2)_")"
	if rand=3 quit "("_$$zero(depth1)_"'="_$$one(depth2)_")"
	if rand=4 quit "("_$$one(depth1)_">"_$$zero(depth2)_")"
	if rand=5 quit "("_$$zero(depth1)_"<"_$$one(depth2)_")"
	if rand=6 quit "("_$$one(depth1)_"'<"_$$zero(depth2)_")"
	if rand=7 quit "("_$$zero(depth1)_"'>"_$$one(depth2)_")"
	if rand=8 quit "("_$$one(depth1)_">="_$$zero(depth2)_")"
	if rand=9 quit "("_$$zero(depth1)_"<="_$$one(depth2)_")"
	if rand=10 quit "("_$$zero(depth1)_"["_$$zero(depth2)_")"
	if rand=11 quit "("_$$one(depth1)_"["_$$one(depth2)_")"
	if rand=12 quit "("_$$one(depth1)_"]"_$$zero(depth2)_")"
	if rand=13 quit "("_$$one(depth1)_"]]"_$$zero(depth2)_")"
	if rand=14 quit "("_$$zero(depth1)_"'["_$$one(depth2)_")"
	if rand=15 quit "("_$$one(depth1)_"'["_$$zero(depth2)_")"
	if rand=16 quit "("_$$zero(depth1)_"']"_$$one(depth2)_")"
	if rand=17 quit "("_$$zero(depth1)_"']]"_$$one(depth2)_")"
	if rand=18 quit "("_$$one(depth1)_"?1""1"""_")"
	if rand=19 quit "("_$$zero(depth1)_"?1""0"""_")"
	if rand=20 quit "("_$$one(depth1)_"'?1""0"""_")"
	if rand=21 quit "("_$$zero(depth1)_"'?1""1"""_")"
	if rand=22 quit "("_"'"_$$zero(depth1)_")"
	if rand=23 quit "("_$$one(depth1)_"!"_$$one(depth2)_")"
	if rand=24 quit "("_$$one(depth1)_"!"_$$zero(depth2)_")"
	if rand=25 quit "("_$$zero(depth1)_"!"_$$one(depth2)_")"
	if rand=26 quit "("_$$zero(depth1)_"'!"_$$zero(depth2)_")"
	if rand=27 quit "("_$$one(depth1)_"&"_$$one(depth2)_")"
	if rand=28 quit "("_$$zero(depth1)_"'&"_$$one(depth2)_")"
	if rand=29 quit "("_$$one(depth1)_"'&"_$$zero(depth2)_")"
	if rand=30 quit "("_$$zero(depth1)_"'&"_$$zero(depth2)_")"
	if rand=31 quit "('"_$$zero(depth1)_")"
	if rand=32 quit $$selecthelper(1,depth1,depth2)
	quit

selecthelper(return,depth1,depth2)
	new numterms,i,choice,retexpr,retstr
	set numterms=$random(4)
	set:0=return retexpr=$$zero(depth2)
	set:1=return retexpr=$$one(depth2)
	set retstr="($select("
	for i=1:1:numterms do
	. set choice=$random(3)
	. set:0=choice retstr=retstr_$$zero(depth1)_":"_$$anyexpr(depth2)
	. set:1=choice retstr=retstr_$$one(depth1)_":"_retexpr
	. set:2=choice retstr=retstr_$$zero(depth1)_":"_$$anyexpr(depth2)
	. set retstr=retstr_","
	; In case `1=choice` was never chosen in above for loop, choose it as last term unconditionally
	set retstr=retstr_$$one(depth1)_":"_retexpr
	set retstr=retstr_"))"
	quit retstr

anyexpr(depth)
	; Returns a random expression that evaluates to 0 or 1
	new rand
	set rand=$random(2)
	quit:0=rand $$zero(depth)
	quit $$one(depth)

