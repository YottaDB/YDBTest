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
; Cases for r208/for_undef_lvtree-ydb1334 : a FOR with a subscripted control variable whose initial value is an
; undefined local variable
;
ydb1334
	quit
	; Each case sets up the local variable abc, then runs a FOR whose control variable is a new node of abc
	; and whose initial value is an undefined node of abc. The FOR creates the control variable before it
	; evaluates the initial value, so the LVUNDEF error deletes it again. The case then checks the tree:
	; the control variable node and the nodes the FOR created above it are gone, $QUERY visits every node
	; that was set, and the nodes can be set and killed.
minimal	; The smallest case: the lookup of the initial value takes a different path than the control variable
	set abc(2)=1
	do try("for abc(1,1)=abc(3)","abc(1)")
	quit
small	; A first level numeric subscript, between string subscripts
	set abc("",1)=1,abc("aaa",1)=1
	do try("for abc(5,""ddx"")=abc(""aaa"")","abc(5)")
	quit
deep	; Three levels created by the FOR, in a larger tree, with initial values whose lookups take different paths
	new i,code
	for i=1:1:50 set abc("k"_i,1)=i,abc(i/7,"s"_i)=i
	for i=1:1:50 set code(i)="for abc(25.5,""x"",""y"")=abc("_(i/7)_",""none"")"
	do try(.code,"abc(25.5)")
	quit
sibling	; The control variable node has a sibling, so only the control variable node is deleted
	set abc("",1)=1,abc("aaa",1)=1,abc(5,"q")=1
	do try("for abc(5,""ddx"")=abc(""aaa"")","abc(5,""ddx"")")
	quit
valued	; The node above the control variable has a value, so only the control variable node is deleted, and the tree of
	; the first level subscripts keeps its lastLookup clue. The SETs right after the FOR use that clue.
	new i,n,node,ecode
	set abc(1)=1,abc(2)=2,abc(3)=3
	do run("for abc(1,1)=abc(4)")
	set abc(5)=5,abc(6)=6
	write $select(ecode[",M6,":"PASS",1:"WRONG")," : the FOR issued LVUNDEF",!
	set node="abc",n=0
	for  set node=$query(@node) quit:(""=node)!(10<n)  set n=n+1
	write $select(5=n:"PASS",1:"WRONG")," : $QUERY visits the 5 nodes",!
	write $select(1=$get(abc(1)):"PASS",1:"WRONG")," : abc(1) still has its value",!
	quit
otherchild	; The node above the control variable has no value but has another child, so only the control variable node is
	; deleted, and the tree of the first level subscripts keeps its lastLookup clue. The SETs right after the FOR use
	; that clue.
	new i,n,node,ecode
	set abc(1,2)=1,abc(2)=2,abc(3)=3
	do run("for abc(1,1)=abc(4)")
	set abc(5)=5,abc(6)=6
	write $select(ecode[",M6,":"PASS",1:"WRONG")," : the FOR issued LVUNDEF",!
	set node="abc",n=0
	for  set node=$query(@node) quit:(""=node)!(10<n)  set n=n+1
	write $select(5=n:"PASS",1:"WRONG")," : $QUERY visits the 5 nodes",!
	write $select(1=$get(abc(1,2)):"PASS",1:"WRONG")," : abc(1,2) still has its value",!
	quit
try(code,gone)	; Run "code" (or each "code(i)"), which must issue LVUNDEF, then check the tree
	new n1,n2,ecode,node,i,ok
	set n1=$$count,ok=1
	if $data(code)#2 do run(code) set ok=ecode[",M6,"
	else  for i=1:1 quit:'$data(code(i))  do run(code(i)) set:'(ecode[",M6,") ok=0
	write $select(ok:"PASS",1:"WRONG")," : the FOR issued LVUNDEF",!
	write $select('$data(@gone):"PASS",1:"WRONG")," : $data(",gone,")=0",!
	set n2=$$count
	write $select(n1=n2:"PASS",1:"WRONG")," : $QUERY visits the same ",n1," nodes as before the FOR",!
	zwrite:n1<5 abc
	set node="abc" for i=1:1 set node=$query(@node) quit:""=node  set @node=-i
	set node="abc" for  set node=$query(@node) quit:""=node  kill @node
	write $select('$data(abc):"PASS",1:"WRONG")," : every node could be set and killed",!
	quit
run(code)	; Run "code" with an error trap that records $ECODE and returns
	new $etrap
	set $etrap="set ecode=$ecode,$ecode="""" quit"
	xecute code
	quit
count()	; The number of nodes of abc, by $QUERY
	new node,n
	set node="abc",n=0
	for  set node=$query(@node) quit:""=node  set n=n+1
	quit n
