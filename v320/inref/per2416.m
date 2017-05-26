PER2416	; ; ; Test for accvio on lock after an extended reference
	;
	n (act) i '$d(act) n act s act="s zp=$zpos"
	s cnt=0 l
	s x=$d(^|"per2416.gld"|a)
	l ^a
	zshow "l":x
	i $d(x("L",1)),x("L",1)["^a"
	e  s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
