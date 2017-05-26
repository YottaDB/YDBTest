TPTEST3	; ; ; test 2 regions
	;
	n (act)
	i '$d(act) n act s act="w $zpos"
	s cnt=0
	v "gdscert":1
	f i=1,2 s ^a(i_$j(i,140),"FOO")="b"_$j(i,140)
	f i=1 s ^b("FOO",i_$j(i,140))="a"_$j(i,140)
	tstart ():serial
	k ^a(2_$j(2,140))
	trollback
	i '$d(^b("FOO")) s cnt=cnt+1 x act
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
