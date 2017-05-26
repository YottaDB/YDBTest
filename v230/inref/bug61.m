main	d proc
	d chk
	q
proc	s x=$j("",20000),a("str","qq")=x
	s a("str",1)=1 n (a,x) k a("str",1)
	f i=1:1:20 s a("str","qq")="$"_a("str","qq")
	d chk
	q
chk	w $d(x),?10,$l(x),!,$d(a),?10,$d(a("str")),?20,$d(a("str","qq")),!
	q
