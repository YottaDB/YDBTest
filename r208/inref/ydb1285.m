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
; YDB#1285 : $QUERY(lvn,-1) must return an ancestor of lvn that has a value but no descendants,
; when lvn does not exist, as that ancestor collates immediately before lvn.
;
; Each label below is run by revquery_ancestor-ydb1285.csh.
;
ydb1285	;
	write "Run one label at a time. See revquery_ancestor-ydb1285.csh",!
	quit
	;
direct	; $QUERY(lvn,-1) with the direction known at compile time
	new x,y,w,z,n,b
	set x(5,-1,"b",-2)=1,x("a")=2
	do chk("$query(x(""a"",4),-1)",$query(x("a",4),-1),"x(""a"")")
	do chk("$query(x(""a"",""""),-1)",$query(x("a",""),-1),"x(""a"")")
	set x("a",5)=3
	do chk("$query(x(""a"",4),-1) after set x(""a"",5)=3",$query(x("a",4),-1),"x(""a"")")
	set y("a")=2
	do chk("$query(y(""a"",4),-1)",$query(y("a",4),-1),"y(""a"")")
	set w(1)=1,w(2)=2
	do chk("$query(w(2,""x"",""y""),-1)",$query(w(2,"x","y"),-1),"w(2)")
	set n(1)=1,n(1.5)=2
	do chk("$query(n(1.5,-3,""q""),-1)",$query(n(1.5,-3,"q"),-1),"n(1.5)")
	set z(1)=1,z(2)=2,z(2,"k")=3
	kill z(2,"k")
	do chk("$query(z(2,""k"",1),-1) after kill z(2,""k"")",$query(z(2,"k",1),-1),"z(2)")
	set b=1
	do chk("$query(b(1,2),-1)",$query(b(1,2),-1),"b")
	quit
	;
runtime	; $QUERY(lvn,dir) with the direction known only at run time, and $QUERY(@ref,-1)
	new x,y,d,r
	set x(5,-1,"b",-2)=1,x("a")=2,y("a")=2,d=-1
	do chk("$query(x(""a"",4),d) with d=-1",$query(x("a",4),d),"x(""a"")")
	do chk("$query(y(""a"",4),d) with d=-1",$query(y("a",4),d),"y(""a"")")
	set r="x(""a"",4)"
	do chk("$query(@r,-1) with r=""x(""""a"""",4)""",$query(@r,-1),"x(""a"")")
	set r="y(""a"",4)"
	do chk("$query(@r,d) with r=""y(""""a"""",4)"" and d=-1",$query(@r,d),"y(""a"")")
	quit
	;
revcoll	; $QUERY(lvn,-1) with a local collation sequence that reverses the order of strings
	new x
	set x("b","c")=1,x("a")=2
	do chk("$order(x(""""))",$order(x("")),"b")
	do chk("$query(x(""a"",""z""),-1)",$query(x("a","z"),-1),"x(""a"")")
	quit
	;
random	; Compare $QUERY(lvn,-1) with $QUERY(gvn,-1) over random trees and random starting nodes
	; The subscripts of both results are compared, after removing the variable names lv and ^gv.
	new lv,subs,nsubs,tree,lprobe,gprobe,i,j,lres,gres,mismatch,ntree,nprobe
	set subs="1,2,-1,1.5,""a"",""b""",nsubs=$length(subs,",")
	set ntree=500,nprobe=50,mismatch=0
	for tree=1:1:ntree do
	. kill lv,^gv
	. for i=1:1:1+$random(8) set @$$ref("lv",subs,nsubs,1+$random(3))=i
	. merge ^gv=lv
	. for j=1:1:nprobe do
	. . set lprobe=$$ref("lv",subs,nsubs,1+$random(4)),gprobe="^gv"_$extract(lprobe,3,$length(lprobe))
	. . set lres=$query(@lprobe,-1),gres=$query(@gprobe,-1)
	. . quit:$extract(lres,3,$length(lres))=$extract(gres,4,$length(gres))
	. . set mismatch=mismatch+1
	. . quit:5<mismatch
	. . write "  $query(",lprobe,",-1) returned [",lres,"] but $query(",gprobe,",-1) returned [",gres,"] in the tree",!
	. . zwrite lv
	kill lv,^gv
	do chk("the count of $query(lvn,-1) results that differ from $query(gvn,-1), over "_(ntree*nprobe)_" starting nodes,",mismatch,0)
	quit
	;
ref(name,subs,nsubs,depth)	; A reference to name with depth subscripts chosen at random from subs
	new i,r
	set r=name_"("
	for i=1:1:depth set r=r_$piece(subs,",",1+$random(nsubs))_$select(i<depth:",",1:")")
	quit r
	;
chk(expr,actual,expected)
	if actual=expected write "PASS : ",expr," returned ",actual,! quit
	write "WRONG : ",expr," returned [",actual,"], expected [",expected,"]",!
	quit
