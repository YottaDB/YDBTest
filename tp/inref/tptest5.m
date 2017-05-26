TPTEST5	; ; ; test for gv_target problems
	;
	n act s cnt=0
	v "gdscert":1
	i '$d(act) n act s act="w !,$zpos b"
	tstart ():serial
	s ^a(1)=1
	s ^a(2)=2
	s ^b(1)=1
	tcommit
	zl "tptest5a"
	d test^tptest5a(3)
	tstart ():serial
	s ^a(3)=$j("this is a big non tp set",200)
	tcommit
	d test^tptest5a(4)
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
