bug73	;
	;s rpcd=1 ;"prds01"
	;s ox="abrtd" ;$o(^prds("rp",rpcd,"st",""))
	;s xx=^prds("stxf1",ox)
	k ^foo
	s ^foo(1)=12
	s xx=^foo(1)
	s sa(xx)="."
lp	;
	;f i=12,10,1,2,7,3,5,6,13,4,11 s sa(i)="."
	w !,$d(sa(12)),! ;k sa(12)
	s n=""
	f i=1:1:20 s n=$o(sa(n)) q:n=""  w !,i,":",n,":",$d(sa(n))
	q
	k sa
	r !,xxx
	g lp
	q
