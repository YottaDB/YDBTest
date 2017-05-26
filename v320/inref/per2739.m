per2039	; ; ; test that $r does not produce negative numbers
	;
	n (act)
	i '$d(act) n act s act="w !,lim"
	s cnt=0
	f i=2:1:31 s lim=2**i-1 f j=1:1:100000 i $r(lim)<0 s cnt=cnt+1 x act q
	w !,$s(cnt:"BAD",1:"OK")," from ",$t(+0)
	q
