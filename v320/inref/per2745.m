per2745	; ; ;test that the generated range is ok
	;
	n (act)
	i '$d(act) n act s act="w !,lim,?20,max"
	s cnt=0,max=0
	f i=4:1:31 s lim=2**i-1 d
	. f j=1:1:100000 s x=$r(lim) i x>max s max=x
	. i (lim*.1)<(lim-max) s cnt=cnt+1 x act
	w !,$s(cnt:"BAD",1:"OK")," from ",$t(+0)
	q
