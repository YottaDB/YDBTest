jobtst	;
	;no way to test job command in UNIX, that I know of --Nergis
	d ^init(timeout,longwait)    
	d INT^%TI
	tstart ():serial
	s ^tbegtp=%TN
	job jobit::10
	h 3
	l ^alfa:0
	w "Should never come here",!
	tcommit
	d ^finish
	l
	q
jobit 	;
	;hang for 30 sec in increments of 1
	l ^alfa
	s duration=10
	s ^j=0
loop	h 1
	s ^j=^j+1
	if ^j<duration goto loop
	w "Waited for ",duration," seconds in job with one second hangs",!
	l
	q
