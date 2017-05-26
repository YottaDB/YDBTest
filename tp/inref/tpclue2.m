; write a new block in two separate transactions 
; This program tests a transaction utilizing a clue provided
; by a prior transaction.  This test passed as of GT.M V3.2-FT11.
TPCLUE2
	n (act)
	i '$d(act) n act s act="w var,"" = "",$g(@var(sub),""**UNDEF**""),!"
	v "gdscert":1
	s cnt=0
	s ^A(1)=1
	s ^A(2)=2
	ts
	s ^B(1)=1
	tc
	ts
	s ^B(2)=2
	tc
	f var="^A","^B" f sub=1:1:2 Do
	. s cmp=sub
	. i @var@(sub)'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
