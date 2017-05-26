per2733	; ; ; test case from sca that accvios
	;
	n (act)
	i '$d(act) n act s act="s zp=$zpos"
	s cnt=0
	s x=$j(0,0,32701)
 	i $l(x)'=32703 s cnt=cnt+1 x act
	w !,$s(cnt:"BAD",1:"OK")," from ",$t(+0)
	q
