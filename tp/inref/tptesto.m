TPTESTO	; ; ; right index split with chain to the left and right
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	tstart ():serial
	f i=3:-1:1 s ^a(i_$j(i,240))=$j(i,240)
	tcommit
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
