;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
misceval;
	; Miscellaneous evaluation-related test cases for GTM-3907, GTM-6395, GTM-5896, and related boolean issues.
	;
	new $etrap
	set $etrap="do etr"
	set TRUE=1,FALSE=0
	set env("gtm_side_effects")=+$ztrnlnm("gtm_side_effects")
	set env("gtm_boolean")=+$ztrnlnm("gtm_boolean")
	write !
	write "misceval test run begins... gtm_side_effects=",env("gtm_side_effects")," gtm_boolean=",env("gtm_boolean"),!
	set ntests=18	; Total number of test cases
	set passcnt=0
	for i=1:1:ntests do @("test"_i_"^misceval")
	if ntests=passcnt write "ALL PASS",!
	else  write "FAILURES ("_(ntests-passcnt)_"). See above.",! zwrite env
	quit
	;
init	kill (TRUE,FALSE,ntests,env,i,passcnt)
	kill ^incr,^bogus,^unknwn,^X,^Y,^Z
	kill ^VCORR,^VCOMP
	set errcnt=0
	view "UNDEF"
	quit
	;
check	set corr=TRUE
	if ($data(^VCORR("$Reference"))#10)&($get(^VCORR("$Reference"))'=$get(^VCOMP("$Reference"))) set corr=FALSE
	if ($data(^VCORR("Exp"))#10)&($get(^VCORR("Exp"))'=$get(^VCOMP("Exp"))) set corr=FALSE
	if FALSE=corr do
	.	write "FAIL: test"_testid_" (expected ^VCORR, actual ^VCOMP)",!
	.	zwrite ^VCORR,^VCOMP
	else  set passcnt=passcnt+1
	quit
	;
	; Extrinsic side-effect used below
I()	set %="^Y"
	quit 1
	;
II()	kill x(0)
	for j=1:1:1000 set y(j)="wrong"		; enough to reuse all discarded lv slots, including that of x(0)
	quit 0
	;
etr	set $ecode=""
	set loc=$stack($stack-1,"PLACE")
	set next=$zlevel_":"_$piece(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set errcnt=errcnt+1
	zgoto @next
	halt
	;
test1	do init^misceval set testid=1
	set j=0,^incr(1)=TRUE,^bogus(0,TRUE)="^unknwn(0)",^bogus(1,TRUE)="^unknwn(1)",^unknwn(0)=TRUE,^unknwn(1)=FALSE
	set Exp=TRUE&@^bogus(j,1&^incr($incr(j)))
	set ^VCOMP("$Reference")=$Reference,^VCOMP("Exp")=Exp
	set ^VCORR("$Reference")="^unknwn(0)",^VCORR("Exp")=TRUE
	if 0=env("gtm_side_effects") set ^VCORR("$Reference")="^unknwn(1)",^VCORR("Exp")=FALSE
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test2	do init^misceval set testid=2
	set ^bogus(0)="^unknwn(0)",^bogus(1)=FALSE,^unknwn(1)=TRUE
	set Exp=TRUE&$Get(@^bogus(0),^(1))
	set ^VCOMP("$Reference")=$Reference,^VCOMP("Exp")=Exp
	set ^VCORR("$Reference")="^unknwn(1)",^VCORR("Exp")=TRUE
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test3	do init^misceval set testid=3
	set ^bogus(0)="^unknwn(1)",^bogus(3)=-1,^unknwn(3)=1,(^unknwn(0),^unknwn(1),^unknwn(2))=0
	set Exp=TRUE&$Order(@^bogus(0),^(3))
	set ^VCOMP("$Reference")=$Reference,^VCOMP("Exp")=Exp
	set ^VCORR("$Reference")="^unknwn(3)",^VCORR("Exp")=TRUE
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test4	do init^misceval set testid=4
	set str="^x(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)"
	set Exp=$name(@str)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")=str
	do check^misceval
	quit
	;
test5	do init^misceval set testid=5
	set x(1,2)="right",x(2,2)="wrong"
	set j=1,r(1)=x(j,$incr(j))
	set j=1,r(2)=@"x(j,$incr(j))"
	set j=1,r(3)=@"x(j)"@($incr(j))
	set j=1,r(4)=$Name(x(j,$incr(j)))
	set j=1,r(5)=$Name(@"x(j,$incr(j))")
	set j=1,r(6)=$Name(@"x(j)"@($incr(j)))
	set Exp=r(1) for j=2:1:6 set Exp=Exp_":"_r(j)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")="right:right:right:x(1,2):x(1,2):x(1,2)"
	if 0=env("gtm_side_effects") set ^VCORR("Exp")="wrong:wrong:wrong:x(2,2):x(2,2):x(2,2)"
	do check^misceval		; Fails with V60000. Fixed with GTM-3907/GTM-5896
	quit
	;
test6	do init^misceval set testid=6
	set (^X,^Y,^Z)=1,str="@%",%="^X"
	set Exp=$Name(@str,$$I)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")="^X"
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test7	do init^misceval set testid=7
	set (^X,^Y,^Z)=1,str="@%",%="^X"
	set Exp=$Order(@str,$$I)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")="^Y"
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test8	do init^misceval set testid=8
	set x(0)="right"
	set Exp=$Get(x(0),$$II)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")="right"
	do check^misceval		; Fails with V60000. Fixed with GTM-3907
	quit
	;
test9	do init^misceval set testid=9
	set sub2="B(@(()(",x("A",sub2)="FALSE",y(sub2)=TRUE,a="A",sub1="a",x("A")="y",parent="@x(@sub1)"
	set Exp=@parent@(sub2)
	set ^VCOMP("Exp")=Exp
	set ^VCORR("Exp")=TRUE
	do check^misceval		; Fails with V60000. Fixed with GTM-5896
	quit
	;
test10	do init^misceval set testid=10
	set j=1,x(2)=TRUE,(y(1),y(2))=FALSE
	merge y(j)=x($incr(j))
	set ^VCOMP("Exp")=y(1)
	set ^VCORR("Exp")=TRUE
	if 0=env("gtm_side_effects") set ^VCORR("Exp")=FALSE
	do check^misceval		; Fails with V60000. Fixed with GTM-3907 (similar to GTM-6395)
	quit
	;
test11	do init^misceval set testid=11
	set j=1,x(2)=TRUE,(y(1),y(2))=FALSE
	merge @"y(j)"=x($incr(j))
	set ^VCOMP("Exp")=y(1)
	set ^VCORR("Exp")=TRUE
	if 0=env("gtm_side_effects") set ^VCORR("Exp")=FALSE
	do check^misceval		; Fails with V60000. Fixed with GTM-3907 (similar to GTM-6395)
	quit
	;
test12	do init^misceval set testid=12
	set x(0)=1 hang (@"x"@(0)),2	; none of these commands should give a syntax error
	set file="/dev/null" open file use file
	write (@"x"@(0))
	write (@"x"@(0)),!
	close file
	set %="^x" lock +(@%@(0))	; Note that @x@() indirection is not techically allowed by the M standard for lock names,
					; only for local and global variable names. Parentheses around the lock name are also not
					; really allowed. But we support these things anyway since they are reasonable syntax, and
					; people use them.
	lock
	set %="^x" lock +(@%@(0)):0
	lock
	set ^VCOMP("Exp")=errcnt
	set ^VCORR("Exp")=0
	do check^misceval		; Fails with V60001 only. Fixed with GTM-7609.
	quit
	;
test13	do init^misceval set testid=13
	set Indr0="@",@Indr0="Hello"
	set ^Indr0="@",@^Indr0="Hello"
	set Indr(1)="@",@Indr(1)="Hello"
	set indir2="@",myvar(@indir2)="Hello"
	set ^VCOMP("Exp")=$data(myvar)_"|"_errcnt
	set ^VCORR("Exp")=0_"|"_4	; expect 4 errors and myvar to remain unset
	do check^misceval		; Fails with V60001 and earlier versions. Fixed with GTM-4324.
	quit
	;
test14	do init^misceval set testid=14
	view "NOUNDEF"
	new i
	set x="y"_"y"			; make sure x points into stringpool
	kill x
	for i=1:1:10000 set z(i)="a"_i	; fill up stringpool a bit
	view "STP_GCOL"			; force stringpool garbage collection
	kill z
	set @x@(1)="asdf"		; expect an error and nothing to be set
	set b=0
	for i=1:1:10000 set b=b+$data(@("a"_i))
	set ^VCOMP("Exp")=b_"|"_errcnt
	set ^VCORR("Exp")=0_"|"_1
	do check^misceval		; Fails with V60000 and earlier version. Fixed with GTM-5896.
	quit
	;
test15	do init^misceval set testid=15
	new exp;
	kill ^A set var="^A+1" set @var=1
	set exp(1)=$get(^A,0)
	kill ^A set var="^A.1" set @var=1
	set exp(2)=$get(^A,0)
	kill ^A set var="^A&1" set @var=1
	set exp(3)=$get(^A,0)
	set ^VCOMP("Exp")=errcnt_exp(1)_exp(2)_exp(3)
	set ^VCORR("Exp")="3000"
	do check^misceval		; Fails with V60001 and earlier versions. Fixed with GTM-5284.
	quit
	;
test16	do init^misceval set testid=16
	new ivar
	set correct=0
	set ivar="IVAR5678"_$c(255,0,2,65)
	set @ivar=ivar				; Expect a syntax error
	set:errcnt=1 correct=correct+1
	set ivar="IVAR5678"_$c(65,0,2,65)
	set @ivar=ivar				; Expect a syntax error
	set:errcnt=2 correct=correct+1
	set ivar="IVAR5678"_$c(255)
	set @ivar=ivar				; Expect a syntax error
	set:errcnt=3 correct=correct+1
	set ivar="a"_$c(5)_"b"
	set @ivar=ivar				; Expect a syntax error
	set:errcnt=4 correct=correct+1
	set ivar="IVAR5678"_$c(0)
	set @ivar=ivar				; This is reasonable. We'll allow it.
	set:errcnt=4 correct=correct+1
	set ^VCOMP("Exp")=correct_"|"_$get(IVAR5678)
	set ^VCORR("Exp")=5_"|"_"IVAR5678"_$c(0)
	do check^misceval		; GTM-5284.
	quit
	;
test17	do init^misceval set testid=17
	kill ^a
	set str="^a("""_$c(0,1)_""")"
	set @str=1			; This should wind up setting ^a...
	set ^VCOMP("Exp")=errcnt_"|"_$data(^a)
	set ^VCORR("Exp")=0_"|"_10
	do check^misceval		; Fails with V60001 and earlier versions. Fixed with GTM-5284. Fixed again in V63001A
	quit
	;
test18	do init^misceval set testid=18
	set depth=1000,expr="x",x=1
	for i=1:1:depth Set expr="(x)+("_expr_")"
	xecute "set %="_expr		; Recursion during compilation should NOT blow the C stack
	set ^VCOMP("Exp")=%
	set ^VCORR("Exp")=1001
	do check^misceval		; Fails with V60001 and earlier versions. Fixed with GTM-7634.
	quit
	;
