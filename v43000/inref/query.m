;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tq ; test $query
 n e1,e2,local,one,two
 ;
 s e1="first",e2="second"
 s local(1)="local"
 s one="one",one(1)=1,one(1,2,3,4)=1234,one(3)=3
 k ^one m ^one=one
 s two=2,two(2)=2,two(2,2,2,2)=2222
 ;k ^|e2|two m ^|e2|two=two
 k ^|"second"|two s ^|e2|two(2)=2,^|e2|two(2,2,2,2)=2222,^|e2|two=2
 s ^|"second"|two(4,4)=44
 f i=1:50:2500 s local("i",i)="i"_i,^|e2|two("i",i)="i"_i,^|e1|one("i"_i)="i"_i
;
 s x=$q(local) d show("local(1)",x)
 s x=$q(^one) d show("^one(1)",x)
 s x=$q(^|"second"|two) d show("^|""second""|two(2)",x)
 s x=$q(^one(^|"second"|two)) d show("^one(3)",x)
 s x=^|"second"|two(2),x=$q(^(2)) d show("^|""second""|two(2,2,2,2)",x)
 s x=$q(^(2)) d show("^|""second""|two(2,2,2,2)",x)	; test that previous $query does not break $reference (GTM-7810)
 s x=$q(^|"second"|two),y=$q(local) d show("^|""second""|two(2)",x),show("local(1)",y)
 s x=$q(^|"second"|two),y=$q(^one) d show("^|""second""|two(2)",x),show("^one(1)",y)
 f x="local","^one","^|""first""|one","^|""second""|two" f  d  q:x=""
 . i $d(@x)#2 w !,x," = ",@x
 . s x=$q(@x)
 . q
 q
show(exp,seen) n i,l,le,ls
 w !,"Expected '",exp,"',",!?4," got '",seen,"'."
 q:exp=seen
 s le=$e(exp),ls=$l(seen),l=le s:ls>l l=ls
 f i=1:1:l w:$e(exp,i)'=$e(seen,i) !?10,"Char ",$j(i,2),": ",$a(exp,i)," <> ",$a(seen,i)
 q
