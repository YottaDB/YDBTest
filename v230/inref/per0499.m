per0499	;per0499 - local arrays get crossthreaded
	;
	k
	s x(5)=$c(11)
	w !,$s($d(x(30,5)):"BAD result",1:"OK")," from test of integer subscripts in local arrays "
	q
