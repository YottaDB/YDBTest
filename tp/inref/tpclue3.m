; write multiple existing blocks in two separate transactions 
; This program tests a transaction utilizing multiple clues provided
; by a prior transaction.  With GT.M V3.2-FT11 it failed
; with TP Commit Failure.
;
TPCLUE3
	n (act)
	i '$d(act) n act s act="w var,"" = "",$g(@var(sub),""**UNDEF**""),!"
	v "gdscert":1
	s cnt=0
	s ^A(0)=0
	s ^B(0)=0
	ts
	s ^A(1)=1
	s ^B(1)=1
	tc
	ts
	s ^A(2)=2
	s ^B(2)=2
	tc
	f var="^A","^B" f sub=0:1:2 Do
	. s cmp=sub
	. i @var@(sub)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
