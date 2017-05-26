TPTESTL	; ; ; test repeated rollbacks of kills
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	tstart ():serial
	f i=1:1:20 s ^a(i)=$j(i,990)
	tcommit
	tstart ():serial
	f i=1:1:20 k ^a(i)
	i $trestart<1 trestart
	tcommit
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
