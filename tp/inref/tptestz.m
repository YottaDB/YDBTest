TPTESTZ	; ; ; test of a case of kills in a transaction
	;
	n (act)
	i '$d(act) n act s act="b"
	s cnt=0
	v "gdscert":1
	tstart ():serial
	f i=1,2,3 s ^a(i_$j(i,240))=$j(i,240)
	f i=1,2,3 s ^b(i_$j(i,240))=$j(i,240)
	k ^a
	f i=2 k ^b(i_$j(i,240))
	tcommit
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
