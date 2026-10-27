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
; YDB#1317 : the stages of the r208/query_prev_subs_len-ydb1317 subtest that use reverse $QUERY(), which only
; YottaDB has, kept apart from ydb1317.m so that ydb1317.m also compiles with GT.M. They check that $QUERY() of a
; local whose last subscript is the empty string returns the same node after an earlier $QUERY() of that local
; returned another node whose last subscript is the empty string, and still continues a $QUERY() loop.

stdrev	; Reverse $QUERY() with standard null collation
	new y,b,q
	set y("aa","")=1,y("b","")=2,y("b",5)=3,b(1)=1
	set q=$query(b(1))
	do check^ydb1317($query(y("b",""),-1),"y(""b"",5)","$query(y(""b"",""""),-1) after $query(b(1)) of another variable")
	set q=$query(y("aa"))
	do check^ydb1317($query(y("b",""),-1),"y(""b"",5)","$query(y(""b"",""""),-1) right after a $query() that returned y(""aa"","""")")
	set q=$query(y("b",5),-1)
	view "STP_GCOL"	; move the saved previous result, whose subscripts are copies of literals, before it is compared
	do check^ydb1317($query(y("b",""),-1),"y(""aa"","""")","$query(y(""b"",""""),-1) right after a $query() that returned y(""b"","""")")
	kill y
	set y("aa","")=1,y("b","a")=2
	set q=$query(y("aa"))
	do check^ydb1317($query(y("b",""),-1),"y(""b"",""a"")","$query(y(""b"",""""),-1) where y(""b"","""") has no value, right after a $query() that returned y(""aa"","""")")
	quit

gtmrev	; Reverse $QUERY() with GT.M null collation
	new y,b,q
	set y("aa","")=1,y("b","")=2,y("b",5)=3,b(1)=1
	set q=$query(b(1))
	do check^ydb1317($query(y("b",""),-1),"y(""b"","""")","$query(y(""b"",""""),-1) after $query(b(1)) of another variable")
	set q=$query(y("aa"))
	do check^ydb1317($query(y("b",""),-1),"y(""b"","""")","$query(y(""b"",""""),-1) right after a $query() that returned y(""aa"","""")")
	set q=$query(y("b",5))
	view "STP_GCOL"	; move the saved previous result, whose subscripts are copies of literals, before it is compared
	do check^ydb1317($query(y("b",""),-1),"y(""b"",5)","$query(y(""b"",""""),-1) right after a $query() that returned y(""b"","""")")
	quit

walk	; Walk 400 random trees with forward and reverse $QUERY() loops, allocating a 300KB string at each step so that
	; garbage collections move the saved previous result. Each walk must visit every node with a value once, and the
	; reverse walk must visit them in the reverse order of the forward walk. The fixed seed builds the same trees in
	; every run.
	new t,s,i,j,d,x,subs,seed,q,f,r,n,bad,junk,nsub
	set seed=1317,bad=0
	set subs(0)="""""",subs(1)="-1",subs(2)="0",subs(3)="1",subs(4)="""a""",subs(5)="""bb""",subs(6)="""c""""d""",subs(7)="$C(1)",nsub=8
	for t=1:1:400 do
	. kill x,f,r
	. for i=1:1:1+$$rand(10) do
	. . set s="",d=1+$$rand(3)
	. . for j=1:1:d set s=s_$select(j>1:",",1:"")_subs($$rand(nsub))
	. . set @("x("_s_")")=i
	. set n=0,q="x" for  set q=$query(@q) quit:q=""  set n=n+1,f(n)=q,junk=$justify("",300000) quit:n>100
	. set r=0,q="x(""zzz"")" for  set q=$query(@q,-1) quit:(q="")!(q="x")  set r=r+1,r(r)=q,junk=$justify("",300000) quit:r>100
	. if n'=r set bad=bad+1 write:bad<4 "WRONG : tree ",t," forward visits ",n," nodes, reverse ",r,! quit
	. for i=1:1:n if f(i)'=r(n+1-i) set bad=bad+1 write:bad<4 "WRONG : tree ",t," node ",i," forward ",f(i)," reverse ",r(n+1-i),! quit
	write $select(bad:"WRONG",1:"PASS")," : ",bad," of 400 trees walked differently forward and reverse",!
	quit

rand(m)	; Linear congruential generator, so that every run builds the same trees
	set seed=(seed*1103515245+12345)#2147483648
	quit seed\65536#m
