out	; TRACE turned on inside a routine, off up here.
	d ^badprof
	s h=1
	s dummy=2
	f i=1:1:10 s dummy=i d ^one
	view "TRACE":0:"^TRACE"
	q
