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
; YDB#794 : with standard null collation, reverse $QUERY() of a node whose last subscript is the empty string and
; that has no value returns the last node at that level.

setup	; Check the database layout that the other stages rely on
	if $data(^x)+$data(^a)+$data(^c)+$data(^s(2))+$data(^s("c"))	; open every region
	do check($view("REGION","^x"),"DEFAULT","the region of ^x")
	do check($view("REGION","^a"),"AREG","the region of ^a")
	do check($view("REGION","^c"),"CREG","the region of ^c")
	do check($view("REGION","^s(2)"),"BREG","the region of ^s(2)")
	do check($view("REGION","^s(""c"")"),"DEFAULT","the region of ^s(""c"")")
	do check($$^%PEEKBYNAME("sgmnt_data.null_subs","DEFAULT"),1,"null subscripts of DEFAULT (1 is ALWAYS)")
	do check($$^%PEEKBYNAME("sgmnt_data.null_subs","AREG"),0,"null subscripts of AREG (0 is NEVER)")
	do check($$^%PEEKBYNAME("sgmnt_data.std_null_coll","DEFAULT"),1,"standard null collation of DEFAULT")
	do check($$^%PEEKBYNAME("sgmnt_data.std_null_coll","BREG"),1,"standard null collation of BREG")
	do check($$^%PEEKBYNAME("sgmnt_data.std_null_coll","CREG"),0,"standard null collation of CREG")
	quit

globals	; ^x and ^s use standard null collation, ^s spans regions, and region AREG holding ^a has null subscripts disabled
	new r,q,list,i,l
	kill ^x
	set ^x=0,^x(1)=1,^x(2,1)=2
	do check($query(^x(""),-1),"^x(2,1)","$query(^x(""""),-1)")
	do check($query(^x(2,""),-1),"^x(2,1)","$query(^x(2,""""),-1)")
	do check($query(^x(2,1,""),-1),"^x(2,1)","$query(^x(2,1,""""),-1), with no node under ^x(2,1)")
	set r="^x("""")"
	do check($query(@r,-1),"^x(2,1)","$query(@r,-1) with r=""^x("""""""")""")
	set ^x(3,"",5)=3
	do check($query(^x(3,""),-1),"^x(3,"""",5)","$query(^x(3,""""),-1) where ^x(3,"""") has no value but has a descendant")
	set l(1)=1,list="",q="^x("""")" for i=1:1:20 set q=$query(@q,-1) quit:q=""  set list=list_" "_q if $query(l(1))
	do check(list," ^x(3,"""",5) ^x(2,1) ^x(1) ^x","for  set q=$query(@q,-1) quit:q=""""  from q=""^x("""""""")"", with a $query() of a local in the loop body, visits")
	set ^x("")=4
	do check($query(^x(""),-1),"^x","$query(^x(""""),-1) where ^x("""") has a value")
	kill ^x
	set ^x(1)=1,^x(2,"")=2,^x(2,5)=3
	set list="",q="^x(3)" for i=1:1:20 set q=$query(@q,-1) quit:q=""  set list=list_" "_q kill:$qsubscript(q,$qlength(q))="" @q
	do check(list," ^x(2,5) ^x(2,"""") ^x(1)","a reverse $query() loop from ^x(3) that kills each node whose last subscript is """" visits")
	kill ^x,^d
	set ^x(1)=1,^x("")=2,^x("a")=3,^d("")=1
	set list="",q="^x(""z"")" for i=1:1:20 set q=$query(@q,-1) quit:q=""  set list=list_" "_q if $query(^d)
	do check(list," ^x(""a"") ^x(1) ^x("""")","a reverse $query() loop from ^x(""z"") with a $query(^d) that returns ^d("""") in the loop body visits")
	kill ^a
	set ^a=0,^a(1)=1,^a(2,1)=2
	do check($query(^a(""),-1),"^a(2,1)","$query(^a(""""),-1) in a region with null subscripts disabled")
	kill ^s
	set ^s=0,^s(1)=1,^s(2,1)=2,^s("c")=3
	do check($query(^s(""),-1),"^s(""c"")","$query(^s(""""),-1) of a global that spans regions")
	do check($query(^s(2,""),-1),"^s(2,1)","$query(^s(2,""""),-1) where ^s(2,*) maps to another region")
	quit

gtmnull	; ^c uses GT.M null collation, which the fix does not change
	new q,list,i
	kill ^c
	set ^c=0,^c(-1)=1,^c("")=2,^c("a")=3
	do check($query(^c(""),-1),"^c(""a"")","$query(^c(""""),-1), the last node at that level")
	set list="",q="^c("""")" for i=1:1:20 set q=$query(@q,-1) quit:q=""  set list=list_" "_q
	do check(list," ^c(""a"") ^c("""") ^c(-1) ^c","for  set q=$query(@q,-1) quit:q=""""  from q=""^c("""""""")"" visits")
	quit

locals	; Local variables with standard null collation, which the fix does not change
	new x,q
	set x=0,x(1)=1,x(2,1)=2
	do check($query(x(""),-1),"x(2,1)","$query(x(""""),-1)")
	set x("")=4
	do check($query(x(""),-1),"x(2,1)","$query(x(""""),-1) where x("""") has a value, as the first call")
	do check($query(x(1),-1),"x("""")","$query(x(1),-1)")
	do check($query(x(""),-1),"x","$query(x(""""),-1) right after a $query() that returned x("""")")
	quit

random	; Compare $QUERY(lvn,-1) with $QUERY(gvn,-1) of the same random tree in ^x, and in ^s which spans regions, for every
	; node and every node with an extra trailing "" subscript, other than a reference whose trailing "" node has a value.
	; The fixed seed builds the same trees in every run, so there are 8631 such references in every run. Before each
	; pair of calls, $query(rst(0)) and $query(^zzznone) clear the previous results that $QUERY() saves for locals and
	; for globals, so that each call is a first call.
	new t,s,i,j,d,x,refs,ref,ql,qg,bad,tot,subs,seed,gvn,rst,junk
	set rst(1)=1
	set seed=794,bad=0,tot=0
	set subs(0)="""""",subs(1)="-1",subs(2)="0",subs(3)="1",subs(4)="""a""",subs(5)="""b"""
	for gvn="^x","^s" for t=1:1:500 do
	. kill x,@gvn,refs set refs("("""")")=""
	. if $$rand(2) set x=0,@gvn=0
	. for i=1:1:1+$$rand(8) do
	. . set s="",d=1+$$rand(3)
	. . for j=1:1:d set s=s_$select(j>1:",",1:"")_subs($$rand(6))
	. . set @("x("_s_")")=i,@(gvn_"("_s_")")=i,refs("("_s_")")="",refs("("_s_","""")")=""
	. set ref="" for  set ref=$order(refs(ref)) quit:ref=""  do
	. . quit:($extract(ref,$length(ref)-2,$length(ref))=""""")")&($data(@("x"_ref))#2)
	. . set junk=$query(rst(0)),junk=$query(^zzznone),ql=$query(@("x"_ref),-1)
	. . set junk=$query(^zzznone),qg=$query(@(gvn_ref),-1),tot=tot+1
	. . quit:$select(ql="":qg="",1:(gvn_$extract(ql,2,$length(ql)))=qg)
	. . set bad=bad+1
	. . write:bad<6 "WRONG : $query(x",ref,",-1) is ",ql," but $query(",gvn,ref,",-1) is ",qg,!
	if 'bad write "PASS : $query(,-1) of all ",tot," references matched the global",!
	else  write "WRONG : ",bad," of ",tot," references did not match the global",!
	quit

rand(m)	; Linear congruential generator, so that every run builds the same trees
	set seed=(seed*1103515245+12345)#2147483648
	quit seed\65536#m

check(actual,expected,what)
	if actual=expected write "PASS : ",what," is ",actual,!
	else  write "WRONG : ",what," is ",actual," but expected ",expected,!
	quit
