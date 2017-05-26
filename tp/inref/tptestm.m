TPTESTM	; ; ; test repeated rollbacks of kills
	;
	n (act)
	i '$d(act) n act s act="zp @$zpos"
	s cnt=0
	v "gdscert":1
	f i=1:1:20 s ^a(i)=$j(i,990)
	f i=1:1:18 k ^a(i)
	tstart ():serial
	k ^a(19)
	k ^a(20)
	tcommit
exit	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
