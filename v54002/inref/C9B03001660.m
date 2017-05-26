;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C9B03001660   ; ; ; look for issues with FOR control variables, especially those with subscripts and $INCREMENT(), $$, $&
	;
	new (act)
	if '$data(act) new act set act="write !,$zstatus,! zshow ""VS"""
	new $etrap
	set $ecode="",$zstatus="",$etrap="goto err"
	set zl=$zlevel
	set expect=""
	kill lcnt
	f a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)=1:1:2 i $i(lcnt) i '$d(a),$i(cnt) x act
	kill lcnt
	f a=1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7  if $increment(lcnt) if (lcnt#10)'=$get(a),$increment(cnt) x act
	kill lcnt
	do mess
	for I="1a":1:2 if $increment(lcnt) do chckb,t1 if lcnt'=$get(I),$increment(cnt) x act
	set y="I"
	kill lcnt
	set expect=""
	do mess
	for @y=1:1:2 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I(5)=1:1:2 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	set expect=""
	do mess
	xecute "for I(5)=1:1:2 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act"
	set y="I(5)"
	kill lcnt
	set expect=""
	do mess
	for I=1:1:$$oops(.I) if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I=1:$$oops(.I):4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I=$$oops(.I):1:4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	set y="I"
	kill lcnt
	set expect=""
	do mess
	for @y=1:1:$$oops(.I) if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for @y=1:$$oops(.I):4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for @y=$$oops(.I):1:4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I(5)=1:1:2 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I(5)=1:1:$$oops(.I) if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I(5)=1:$$oops(.I):4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for I(5)=$$oops(.I):1:4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	set y="I(5)"
	kill lcnt
	set expect=""
	do mess
	for @y=1:1:$$oops(.I) if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for @y=1:$$oops(.I):4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	kill lcnt
	set expect=""
	do mess
	for @y=$$oops(.I):1:4 if $increment(lcnt) do chckb,t1 if '$data(I),$increment(cnt) x act
	set expect="UNDEF"
	for a(1)=0,1:1:3 write !,$get(a(1),"UNDEF") kill a(1)
	set expect="UNDEF"
	for a(1)=0,1:1:3 write !,$get(a(1),"UNDEF") new a
	set expect="UNDEF"
	for a(1)=0,1:1:3 write !,$get(a(1),"UNDEF") new (act,b,cnt,expect,zl)
	set y="a(1)"
	set expect="UNDEF"
	for @y=1:1:3 write !,$get(a(1),"UNDEF") kill a
	set y="a(1)"
	set expect="UNDEF"
	for @y=1:1:3 write !,$get(a(1),"UNDEF") new a
	set y="a(1)"
	set expect="UNDEF"
	for @y=1:1:3 write !,$get(a(1),"UNDEF") new (act,b,cnt,expect,zl)
	set expect="UNDEF"
	set (a(0),b)=0,(a(1),i)=1
	set a(i)=$$oops(.a) if $increment(c),2'=$get(a(1)),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(1),i)=1,y="a(i)",z="b(5)"
	for a(i)=2,$$oops(.a),2 for b(5)=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(2),i)=1,y="a(i)",z="b(5)"
	for @y=2,$$oops(.a),2 for b(5)=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(1),i)=1,y="a(i)",z="b(5)"
	for a(i)=2,$$oops(.a),2 for @z=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(1),i)=1,y="a(i)",z="b(5)"
	for @y=2,$$oops(.a),2 for @z=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(2),i)=1,y="@x",x="a(i)",z="b(5)"
	for @y=2,$$oops(.a),2 for b(5)=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(1),i)=1,y="@x",x="a(i)",z="@q",q="b(5)"
	for a(i)=2,$$oops(.a),2 for @z=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	set (a(0),b(0),c)=0,(a(1),b(1),i)=1,y="@x",x="a(i)",z="@q",q="b(5)"
	for @y=2,$$oops(.a),2 for @z=2,$$oops(.b),2 if $increment(c),(2'=$get(a(1)))!(2'=$get(b(5))),$increment(cnt) xecute act
	kill (act,cnt,zl)
	write !
	f a=1 f b=2 f c=3 f d=4 f e=5 f f=6 f g=7 f h=8 f i=9 f j=0 f k=1 f l=2 f m=3 f n=4 f o=5 f p=6 f q=7 f r=8 f s=9 f t=0 f u=1 f v=2 f w=3 f x=4 f y=5 f z=6 f A=7 f B=8 f C=9 f D=0 f E=1 zwr
	kill (act,cnt,zl)
	f a(1)=1 f b(1)=2 f c(1)=3 f d(1)=4 f e(1)=5 f f(1)=6 f g(1)=7 f h(1)=8 f i(1)=9 f j(1)=0 f k(1)=1 f l(1)=2 f m(1)=3 f n(1)=4 f o(1)=5 f p(1)=6 f q(1)=7 f r(1)=8 f s(1)=9 f t(1)=0 f u(1)=1 f v(1)=2 f w(1)=3 f x(1)=4 f y(1)=5 f z(1)=6 f A(1)=7 f B(1)=8 f C(1)=9 f D(1)=0 f F(1)=$i(a(1),b(1)) zwr
	kill (act,cnt,zl)
	set y="a"
	f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=$i(a,a) zwr
	kill (act,cnt,zl)
	set y="a(1)"
	f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=1 f @y=2 f @y=3 f @y=4 f @y=5 f @y=6 f @y=7 f @y=8 f @y=9 f @y=0 f @y=$i(a(1),a(1)) zwr
	kill (act,cnt,zl)
	for a(1)=1:1:3,$$oops(.a)*2 for b(5)=1:1:3,$$oops(.b)*2 quit:2<b(5)  if $increment(c),(""=$get(a(1)))!(""=$get(b(5))),$i(cnt) x act
	else  zwrite a,b
	f a(1)=1:1:3,$$oops(.a)*2 do labb(.b) if $increment(c),(""=$get(a(1)))!(""=$get(b(5))),$increment(cnt) xecute act
	else  zwrite a,b
	f a(1)=1:1:3,$$oops(.a)*2 do labg(.b) if $increment(c),(""=$get(a(1)))!(""=$get(b(5))),$increment(cnt) xecute act
	else  zwrite a,b
	f a(1)=1:1:3,$$oops(.a)*2 do labzg(.b) if $increment(c),(""=$get(a(1)))!(""=$get(b(5))),$increment(cnt) xecute act
	else  zwrite a,b
	kill a
	set a(0)="if $increment(a)",a(1)="for a(2)=1:1:3 if $increment(a) xecute a(0)"
	xecute a(1)
	if 6'=a,$increment(cnt) xecute act
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	quit
oops(x)
	kill x
	quit 2
mess	for i=1:1:1000 set a1001=$char(i#26+65)_i,@a1001=i
	quit
t1	kill (I,act,cnt,expect,i,i5,lcnt,y,zl)
	do ^C9B03001660A
	quit
chckb	new y
	set x="%"
	for  set x=$order(@x) quit:""=x!("a"']x)  i "I"'=x set y=$get(@x) i $char(y#26+65)_y'=x,$increment(cnt) xecute act
	for i=1:1:1000 set a1001=$char(i#26+65)_i if '$get(@a1001,"MISSING")=i write !,"damaged ",a1001,?15,$get(@a1001,"MISSING")
	quit
labb(x)	for x(5)=1:1:3,$$oops(.x) quit:2<x(5)
	quit:$quit x(5)
	quit
labg(x)	for x(5)=1:1:3,$$oops(.x) goto gout:2<x(5)
gout	quit:$quit x(5)
	quit
labzg(x)
	for x(5)=1:1:3,$$oops(.x) if 2<x(5) zgoto -1
	quit:$quit x(5)
	quit
err	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
	f a=1 f b=2 f c=3 f d=4 f e=5 f f=6 f g=7 f h=8 f i=9 f j=0 f k=1 f l=2 f m=3 f n=4 f o=5 f p=6 f q=7 f r=8 f s=9 f t=0 f u=1 f v=2 f w=3 f x=4 f y=5 f z=6 f A=7 f B=8 f C=9 f D=0 f E=1 f F=2 zwr
	f a(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32)=1:1:2 if $increment(lcnt) do chckb,t1 if lcnt'=$get(I),$increment(cnt) x act
	f a=1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8  if $increment(lcnt) do chckb,t1 if lcnt'=$get(I),$increment(cnt) x act
