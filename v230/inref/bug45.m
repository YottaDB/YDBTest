	;bug45--s $p of subscripted variable fails
	k a(1) d proc
	d proc
	s a(1)=7+1
	d proc
	q
proc	w $d(a(1)) i $d(a(1))#10 s w=a(1) w ?5,w,!
	s $p(a(1),"\",2)=0
	w a(1),!
	q
