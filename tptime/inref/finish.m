finish	;
	W !,"Sorry, we should not be here. Something is wrong...",!
	s tendtp=$h
	s elaptime=$$^difftime(tendtp,tbegtp)
	w "Transaction finished in ",elaptime," sec",!
	if elaptime'<longwait  w "Did not time out, TEST FAILED",!
	else  w "Unknown ERROR occured. TEST FAILED",!
	ZSHOW "*"
	q

