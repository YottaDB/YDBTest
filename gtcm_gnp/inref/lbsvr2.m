lbsvr2	; lock ^b at server
	; this won't be able to get it since client is already holding the lock
	; this is a longer-waiting version of lbsvr, since it will wait for client side process to be killed
	w "Will try to lock ^b on the server side. (",$H,")",!
	s h1=$E($H,7,12)
	w "h1:",$$FUNC^%T,!
	l ^b:30
	s stat=$T
	w "LOCK STATUS:",stat,!
	s h2=$E($H,7,12)
	w "h2:",$$FUNC^%T,!
	if 'stat w "OK. Did not get the lock.",!
	e  w "FAIL. Did get the lock.",!
	w "Try again right away...",!
	s h3=$E($H,7,12)
	w "h3:",h3,!
	w "h3:",$$FUNC^%T,!
	l ^b:400
	s stat=$T
	s h4=$E($H,7,12)
	w "h4:",h4,!
	w "h4:",$$FUNC^%T,!
	w "LOCK2 STATUS:",stat,!
	if 'stat w "FAIL2. This time it should have gotten the lock.",!
	e  w "OK2. It did get the lock",!
	w "it took:",h4-h3,!
	q
