per2482	; ; ; test $o() and $zp with big arthimetic on subscripts of local arrays
	;
	n (act)
	i '$d(act) n act s act="s zp=$zpos"
	s cnt=0
	s a(1)="",x=8174995249.88
	i $zp(a(x+.01))'=1 s cnt=cnt+1 x act
	i $o(a(x+.01),-1)'=1 s cnt=cnt+1 x act
	i $o(a(x-.01))'="" s cnt=cnt+1
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
