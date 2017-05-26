; test clues and TP
; This program tests a transaction utilizing multiple clues provided
; by a prior transaction.  With GT.M V3.2-FT11 this test failed
; with TP Commit Failure.
;
TPCLUE5
	n (act)
	i '$d(act) n act s act="w var,"" = "",$g(@(var_""(""_sub_"")""),""**UNDEF**""),!"
	v "gdscert":1
	s cnt=0
	s ^A(0)=0
	s ^B(0)=0
	ts
	s ^A(1)=1
	s ^B(1)=1
	s ^B(1,1)=11
	s ^B(1,1,1)=111
	tc
	ts
	k ^B(1,1,1)
	s ^A(2)=2
	tc
	f var="^A" f sub=0:1:2 Do
	. s cmp=sub
	. i @var@(sub)'=cmp s cnt=cnt+1 x act
	f var="^B" f sub=0,"1,1","1,1,1" Do
	. s cmp=$tr(sub,",") s:cmp=111 cmp="**UNDEF**"
	. i $g(@(var_"("_sub_")"),"**UNDEF**")'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
