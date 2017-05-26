TPTESTJ	; ; ; test a transaction updating more than 13 blocks in the same bitmap
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	tstart ():serial
	f i=1:1:14 s ^a(i)=$j(i,990)
	tcommit
	tstart ():serial
	f i=1:1:14 k ^a(i)
	tcommit
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
