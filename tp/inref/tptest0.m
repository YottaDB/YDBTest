TPTEST0	; ; ; test 2 regions
	;
	n (act)
	i '$d(act) n act s act="w $zpos"
	s cnt=0
	v "gdscert":1
	f i=1 s ^a("FOO",i_$j(i,140))="a"_$j(i,140)
	f i=1,2 s ^b(i_$j(i,140),"FOO")="b"_$j(i,140)
	tstart ():serial
	i $d(^b),$d(^a)
	k ^b(2_$j(2,140))
	tcommit
	i '$d(^b) s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
