loop	;
	s $ZT="d err"
	view "TRACE":1:"^TRACE(""ZMPROF17"")"
	s x=0
	d x
	view "TRACE":0
	zwr ^TRACE
	q
x	;
	s x=x+1
	i x<1026 d x
	e  q
	q
err	;
	s $ZT=""
	w "ERROR"
	q
