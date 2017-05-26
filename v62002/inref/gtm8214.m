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
gtm8214
	set jmaxwait=0
	set ^stop=0
	do ^job("child^gtm8214",1,"""""")
	hang 15
	set ^stop=1
	do wait^job
	quit
child	;
	for i=1:1 quit:^stop=1  do
	. set rand=$random(2)
	. do:1=rand load
	. do:0=rand select
	quit
; (un)Load a trigger
load
	set rand=$random(20),num=rand\2,sign=$select((rand#2):"+",1:"-")
	set line(i)=sign_"^SAMPLE("_num_") -commands=S -xecute=""w 123"" -name=myname"_num
	write line(i),!
	set x=$ztrigger("item",line(i))
	quit
; Select a trigger by global, name or all
select
	new rand,num,name,gbl
	set rand=$random(20),num=rand\2
	set gbl="^SAMPLE("_num_")",name="myname"_num,star="*"
	set rand=$random(11)
	set x=$ztrigger("select",$select(10=rand:star,rand<6:gbl,1:name))
	quit
