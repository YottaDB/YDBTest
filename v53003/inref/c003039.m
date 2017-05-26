x	;
	set ^A=1
	set ^A("b")=1
	write !,$next(^B)
	write !,$next(^A("b"))
	quit
