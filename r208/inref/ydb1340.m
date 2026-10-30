;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; Helper routines for the r208/trig_lvn_limit-ydb1340 subtest. Each label loads a trigger whose subscripts have local
; variable names, then checks the value $ZTRIGGER() returns and, if the trigger loaded, the local variables the
; trigger code sees. It prints PASS or WRONG for each check.
;
ydb1340	;
	quit

chain	; two chained names in each of two subscripts
	new ok
	set ok=$ztrigger("item","+^x(a=b=1:2,c=d=:) -commands=set -xecute=""set ^y=$name(z(a,b,c,d))""")
	do check(ok,1,"$ZTRIGGER() return value")
	kill ^y
	set ^x(1,"z")=1
	do check($get(^y),$name(z(1,1,"z","z")),"local variables seen by the trigger code")
	quit

one31	; 31 chained names in one subscript
	do onesub(31)
	quit

one32	; 32 chained names in one subscript
	do onesub(32)
	quit

one200	; 200 chained names in one subscript
	do onesub(200)
	quit

onesub(n)
	new gbl,i,ok,s
	set gbl="^w"_n,s=""
	for i=1:1:n set s=s_"v"_i_"="
	set ok=$ztrigger("item","+"_gbl_"("_s_"1) -commands=set -xecute=""set ^y=$name(z(v1,v"_n_"))""")
	do check(ok,(n<32),"$ZTRIGGER() return value")
	quit:'ok
	kill ^y
	set @gbl@(1)=1
	do check($get(^y),$name(z(1,1)),"local variables seen by the trigger code")
	quit

sub31	; 31 subscripts, each with one name
	new i,ok,s,t
	set s="",t=""
	for i=1:1:31 set s=s_$select(i>1:",",1:"")_"v"_i_"=*",t=t_$select(i>1:",",1:"")_i
	set ok=$ztrigger("item","+^v("_s_") -commands=set -xecute=""set ^y=$name(z(v1,v31))""")
	do check(ok,1,"$ZTRIGGER() return value")
	kill ^y
	set @("^v("_t_")=1")
	do check($get(^y),$name(z(1,31)),"local variables seen by the trigger code")
	quit

trgfile	; write a trigger file with 200 chained names in one subscript
	new i,s
	set s=""
	for i=1:1:200 set s=s_"v"_i_"="
	open "trig200.trg":newversion
	use "trig200.trg"
	write "+^u("_s_"1) -commands=set -xecute=""set ^y=1""",!
	close "trig200.trg"
	quit

check(got,exp,what)
	if got=exp write "PASS : ",what," is ",got,! quit
	write "WRONG : ",what," is ",got,", expected ",exp,!
	quit
