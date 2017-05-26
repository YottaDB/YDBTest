TPTESTR	; ; ; create delete and recreate a root in a transaction
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	tstart ():serial
	s ^a="a"
	k ^a
	s ^a="aa"
	tcommit
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
