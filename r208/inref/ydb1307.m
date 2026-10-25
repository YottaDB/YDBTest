;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1307 : With standard null collation, $QUERY() of a local variable whose last subscript is the empty string
; returns the node that follows it and never that node itself, whatever the previous $QUERY() returned.

stdnull	; Run with standard null collation for local variables
	new a,b,c,d,q,r,i,list
	set a("")="null",a(-1)="neg",a(1)="one",a("x")="x",a("x","")="xnull",a("x",2)="x2",b(1)=1
	do check($query(a("")),"a(-1)","$query(a("""")), the first call")
	do check($query(a("")),"a(-1)","$query(a("""")) again, right after a $query() that returned a(-1)")
	set q=$query(b(1))
	do check($query(a("")),"a(-1)","$query(a("""")) after $query(b(1)) of another variable")
	set q=$query(a(-1))
	do check($query(a("")),"a(-1)","$query(a("""")) after $query(a(-1))")
	do check($query(a("x","")),"a(""x"",2)","$query(a(""x"","""")), a null subscript at the second level")
	set r="a("""")"
	do check($query(@r),"a(-1)","$query(@r) with r=""a("""""""")""")
	set c("")=1,c("",5)=2,c(1)=3
	do check($query(c("")),"c("""",5)","$query(c("""")) where c("""") has a descendant c("""",5)")
	set d(-1)=1,d(1)=2
	do check($query(d("")),"d(-1)","$query(d("""")) where d("""") does not exist")
	set list="",q="a" for i=1:1:20 set q=$query(@q) quit:q=""  set list=list_" "_q
	do check(list," a("""") a(-1) a(1) a(""x"") a(""x"","""") a(""x"",2)","for  set q=$query(@q) quit:q=""""  from q=""a"" visits")
	quit

gtmnull	; Run with GT.M null collation for local variables, which the fix does not change
	new a,b,q,i,list
	set a("")="null",a(-1)="neg",a(1)="one",a("x")="x",a("x","")="xnull",a("x",2)="x2",b(1)=1
	do check($query(a("")),"a(-1)","$query(a("""")), the first node at that level")
	set q=$query(b(1))
	do check($query(a("")),"a(-1)","$query(a("""")) after $query(b(1)) of another variable")
	set q=$query(a(1))
	do check($query(a("")),"a(""x"")","$query(a("""")) right after a $query() that returned a("""")")
	set list="",q="a" for i=1:1:20 set q=$query(@q) quit:q=""  set list=list_" "_q
	do check(list," a(-1) a(1) a("""") a(""x"") a(""x"",2) a(""x"","""")","for  set q=$query(@q) quit:q=""""  from q=""a"" visits")
	quit

random	; Compare $QUERY() of local x with $QUERY() of global ^x holding the same random tree, for every node and for
	; every node with an extra trailing "" subscript. A global uses standard null collation here. The fixed seed builds
	; the same 500 trees in every run, each with 1 to 8 nodes up to 3 levels deep, so x(""), every node and every node
	; with an extra trailing "" subscript add up to the same 4605 references in every run.
	new t,s,i,j,d,x,refs,ref,ql,qg,bad,tot,subs,seed
	set seed=1307,bad=0,tot=0
	set subs(0)="""""",subs(1)="-1",subs(2)="0",subs(3)="1",subs(4)="""a""",subs(5)="""b"""
	for t=1:1:500 do
	. kill x,^x,refs set refs("("""")")=""
	. for i=1:1:1+$$rand(8) do
	. . set s="",d=1+$$rand(3)
	. . for j=1:1:d set s=s_$select(j>1:",",1:"")_subs($$rand(6))
	. . set @("x("_s_")")=i,@("^x("_s_")")=i,refs("("_s_")")="",refs("("_s_","""")")=""
	. set ref="" for  set ref=$order(refs(ref)) quit:ref=""  do
	. . set ql=$query(@("x"_ref)),qg=$query(@("^x"_ref)),tot=tot+1
	. . quit:$select(ql="":qg="",1:("^"_ql)=qg)
	. . set bad=bad+1
	. . write:bad<6 "WRONG : $query(x",ref,") is ",ql," but $query(^x",ref,") is ",qg,!
	if 'bad write "PASS : $query() of all ",tot," references matched the global",!
	else  write "WRONG : ",bad," of ",tot," references did not match the global",!
	quit

rand(m)	; Linear congruential generator, so that every run builds the same trees
	set seed=(seed*1103515245+12345)#2147483648
	quit seed\65536#m

check(actual,expected,what)
	if actual=expected write "PASS : ",what," is ",actual,!
	else  write "WRONG : ",what," is ",actual," but expected ",expected,!
	quit
