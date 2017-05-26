lbsvr	; lock ^b at server
	; this won't be able to get it since client is already holding the lock
	w "Will try to lock ^b on the server side. (",$H,")",!
	s h1=$H
	l ^b:30
	w $T,!
	s h2=$H
	w "it shouldn't have gotten the lock (time it took:"
	s dif=$$^difftime(h2,h1)
	i dif>29 w ">=30)",!
	e   w "< 30 (= ",dif,"))!!",!
	q
