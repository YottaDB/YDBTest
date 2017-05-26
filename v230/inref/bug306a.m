bug306a	;
	w "should not get here",!
entry	;n (a)
	d subrtn
	q
subrtn	;n (x)
	w "hi",!
	s x=1
	q
