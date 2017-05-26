	;per0305 - implement MDC-A FOR command extension
	s i=0
	f  s i=i+1 q:i>500
	w !,$s(i'=501:"BAD result",1:"OK")," from test of simple argumentless for"
