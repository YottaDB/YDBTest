;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; The purpose of this test is make sure that use of the function
	; $ztrigger is invalid inside an implicit transaction
	;
	; - suicide trigger kills itself and then updates $R!
	; - $ztrigger in triggers (implicit TP)
	; - explicit tstart/tcommit and no trigger context
	; - $ztrigger in triggers : CHAINED
	; - $ztrigger in triggers : NESTED
	; - $ztrigger in triggers : NESTED and CHAINED
	;	need to be wrapped in explicit triggers
nodztrigintrig
	do ^echoline
	do suicide
	do implicit
	do chained
	do nested
	do expchained
	do expnested
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; INTRA handler for test/com/incretrap.m
etraphandler(inerr)
	set err=$piece(inerr,$char(44),2)
	quit:err="%YDB-E-DZTRIGINTRIG"
	use $p
	write "FAIL - unexpected error",!
	if $ztlevel=0 do  quit
	.	write "Not in trigger, this is bad",!
	.	do dumpcontext
	write ^fired($ZTNAme),!
	write inerr,!
	set ^fired($ZTNAme,^fired($ZTNAme))=err
	quit

dumpcontext
	write "FAIL",!			; might get an extra FAIL count, but we shouldn't get any
	write "Context report",!
	if $data(^a) zwrite ^a
	if $data(^b) zwrite ^b
	if $data(^c) zwrite ^c
	if $data(^fired) zwrite ^fired
	if $data(^incretrap) zwrite ^incretrap
	write "Show installed triggers",!
	do all^dollarztrigger
	zwrite
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - $ztrigger in triggers : NESTED and CHAINED
	;	need to be wrapped in explicit triggers
expnested
	do ^echoline
	new $ztwormhole
	write "$gtm_exe/mumps -run expnested^nodztrigintrig",!
	zshow "s":lcn set name=$piece(lcn("S",1),"+",1)
	tstart ()
	do nested
	tcommit
	do ^echoline
	quit
expchained
	do ^echoline
	new $ztwormhole
	write "$gtm_exe/mumps -run expchained^nodztrigintrig",!
	tstart ()
	do chained
	tcommit
	do ^echoline
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - $ztrigger in triggers : NESTED
	;	load trigger C which modifies trigger C
	;	update C
	;	[selective] randomly nest till 127
nested
	do ^echoline
	new $ztwormhole
	write "$gtm_exe/mumps -run nested^nodztrigintrig",!
	new i,stack,tailcmp,mfile,tailed,taildata
	if '$data(name) zshow "s":lcn set name=$piece(lcn("S",1),"+",1)
	set mfile=name_".out",taildata=""
	open mfile:newversion
	do text^dollarztrigger("nestedtfile^nodztrigintrig","nested.trg")
	do file^dollarztrigger("nested.trg",1)
	kill ^a,^c,^fired,i,^incretrap
	set ^incretrap("INTRA")="do etraphandler^nodztrigintrig(%MYSTAT)"
	use mfile
	set ^a=$random(125)+1 ; the number of executions to expect
	set ^c=^a
	close mfile use $p
	if '$data(^fired) do dumpcontext zsystem "cat "_mfile quit
	set stack=$order(^fired(""))
	set $piece(tailcmp,$char(9),$increment(i))=^a
	set $piece(tailcmp,$char(9),$increment(i))=stack
	set $piece(tailcmp,$char(9),$increment(i))="$reference=^c"
	set $piece(tailcmp,$char(9),$increment(i))="executions="_^fired(stack)
	set $piece(tailcmp,$char(9),$increment(i))="$ztvalue="_^c
	do ^tail(-1,mfile,.taildata)
	set tailed=$order(taildata(""))
	if tailed>0,tailcmp=taildata(tailed) write "PASS",!
	else  do dumpcontext zsystem "cat "_mfile
	do ^echoline
	quit
nestedtfile
	;-*
	;+^c -command=S -xecute="do nestedmrtn^nodztrigintrig" -name=nested
	quit
nestedmrtn
	new $estack
	set $ETRAP="do ^incretrap"
	write $ztlevel
	do l^mrtn(3)
	set:$ztlevel<^a x=$increment(^c)
	set:$ztlevel=^a x=$ztrigger("I","-*")
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - $ztrigger in triggers : CHAINED
	;	load three triggers for ^a
	;	- trigger chained1 is innocuos
	;	- trigger chained2 meddles with chained1
	;	- trigger chained3 is innocuos
	;	update ^a twice
	;		both updates will hit %YDB-E-DZTRIGINTRIG
chained
	do ^echoline
	new $ztwormhole
	write "$gtm_exe/mumps -run chained^nodztrigintrig",!
	do text^dollarztrigger("chainedtfile^nodztrigintrig","chained.trg")
	do file^dollarztrigger("chained.trg",1)
	kill ^a,^fired,i
	set $piece(^a,"|",$increment(i))="pass"_i
	set $piece(^a,"|",$increment(i))="pass"_i
	if '$data(^fired) do dumpcontext quit
	if ^fired("chained1#")=2,^fired("chained2#")=2,^fired("chained3#")=2 write "PASS",!
	if $select(^fired("chained1#")'=2:1,^fired("chained2#")'=2:1,^fired("chained3#")'=2:1,1:0) do
	.	write "FAIL",!
	.	zwrite ^a,^fired
	do ^echoline
	quit
chainedtfile
	;-*
	;+^a -command=S -name=chained1 -xecute=<<
	;chained1
	;	do l^mrtn()
	;	set x=$increment(^fired($ZTNAme))
	;	quit
	;>>
	;+^a -command=S -name=chained2  -xecute=<<
	;chained2
	;	set $ETRAP="s $ecode="""" do etraphandler^nodztrigintrig($p($zs,$c(44),2,10)) goto chained2+5"
	;	do l^mrtn()
	;	set x=$increment(^fired($ZTNAme))
	;	set x=$ztrigger("item","-chained1")
	;	quit
	;>>
	;+^a -command=S -name=chained3 -xecute=<<
	;chained3
	;	do l^mrtn(2)
	;	set x=$increment(^fired($ZTNAme))
	;	quit
	;>>
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - $ztrigger in triggers (implicit TP)
	;	load triggers A1 and B, where A1 nests to B
	;	[selective] update ^a firing A1, which fires B
	;		which loads trigger A2 over A1
	;	update ^b which loads trigger A2 over A1
	;	update ^a firing A2
implicit
	do ^echoline
	new $ztwormhole
	write "$gtm_exe/mumps -run implicit^nodztrigintrig",!
	write "implicit 0",!
	do implicitmain(0)
	if '$data(^fired) do dumpcontext quit
	if $select('$data(^fired("implicitA#")):1,'$data(^fired("implicitB#")):1,$data(^fired("implicitA2#")):1,1:0) do
	.	write "FAIL",!
	.	zwrite ^a,^b,^fired
	if $data(^fired("implicitB#")),$data(^fired("implicitA#")) do
	.	if ^fired("implicitA#")=1,^fired("implicitB#")=2  write "PASS",!
	.	if $select(^fired("implicitB#")'=2:1,^fired("implicitA#")'=1:1,1:0) do dumpcontext
	do ^echoline
	new $ztwormhole

	write "implicit 1",!
	do implicitmain(1)
	if '$data(^fired) do dumpcontext quit
	if $select('$data(^fired("implicitA#")):1,'$data(^fired("implicitB#")):1,$data(^fired("implicitA2#")):1,1:0) do
	.	write "FAIL",!,"Executions are not right",!
	.	do dumpcontext
	if $data(^fired("implicitB#")),$data(^fired("implicitA#"))  do
	.	if ^fired("implicitA#")=2,^fired("implicitB#")=3  write "PASS",!
	.	if $select(^fired("implicitA#")'=2:1,^fired("implicitB#")'=3:1,1:0) do
	.	.	write "FAIL",!,"One of the execution counts is off",!
	.	.	do dumpcontext
	do ^echoline
	quit
implicitmain(mode)
	do text^dollarztrigger("implicittfile^nodztrigintrig","implicit.trg")
	do text^dollarztrigger("implicittfile2^nodztrigintrig","implicit2.trg")
	do file^dollarztrigger("implicit.trg",1)
	kill ^a,^b,^fired,^incretrap
	set ^incretrap("INTRA")="do etraphandler^nodztrigintrig(%MYSTAT)"
	set:mode x=$increment(^a)
	set x=$increment(^b)
	set x=$increment(^a)
	quit
implicittfile
	;-*
	;+^a -command=S -xecute="do implicitrtnA^nodztrigintrig" -name=implicitA
	;+^b -command=S -xecute="do implicitrtnB^nodztrigintrig" -name=implicitB
	quit
implicittfile2
	;-implicitA
	;+^a -command=S -xecute="do l^mrtn()" -name=implicitA2
	quit
implicitrtnA
	new $estack
	set $ETRAP="do ^incretrap"
	do l^mrtn(3)
	set x=$increment(^fired($ZTNAme))
	set ^b=($ztvalue*5)+100
	quit
implicitrtnB
	new $estack
	set $ETRAP="do ^incretrap"
	do l^mrtn(3)
	set x=$increment(^fired($ZTNAme))
	set x=$ztrigger("file","implicit2.trg")
	quit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; - suicide trigger kills itself !
suicide
	do ^echoline
	new $ztwormhole
	new $ETRAP
	set $ETRAP="set $ecode="""""
	write "$gtm_exe/mumps -run suicide^nodztrigintrig",!
	do text^dollarztrigger("suicidetfile^nodztrigintrig","suicide.trg")
	do file^dollarztrigger("suicide.trg",1)
	kill ^a,^fired,^incretrap,^stop
	set ^stop=127 ; don't exceed MAXTRIGNEST
	set ^incretrap("INTRA")="do etraphandler^nodztrigintrig(%MYSTAT)"
	set ^incretrap("expected","%YDB-E-STACKCRIT")="set $ecode="""",^stop=$ztlevel+1" ; z/OS hits stack crit
	set x=$increment(^a)
	if '$data(^fired)!'$data(^fired("suicide#")) do dumpcontext write "FAIL",!,"^fired(""suicide#"") is undefined!",!
	else  do
	.	if ^fired("suicide#")=^stop,^a=2 write "PASS",!
	.	if $select(^fired("suicide#")'=^stop:1,^a'=2:1,1:0) write "FAIL",! zwrite ^a,^fired,^stop
	.	write !,"The $ztrigger select should show the suicide trigger",!
	.	do all^dollarztrigger
	do ^echoline
	quit
suicidemrtn
	new $estack
	set $ETRAP="do ^incretrap"
	set r=$reference,doit="set "_r_"=$ztvalue"
	set x=$increment(^fired($ZTNAme))
	set x=$ztrigger("item","-suicide")
	set x=$ztvalue,$ztvalue=$increment(x)
	xecute:$ztlevel<^stop doit ; don't exceed MAXTRIGNEST
	quit
suicidetfile
	;-*
	;+^a -commands=S -xecute="do suicidemrtn^nodztrigintrig" -name=suicide
	quit

