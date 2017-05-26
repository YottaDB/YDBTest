per2607g ; ; ; use two values in a transaction
	;
	tstart ():serial
	s x="foo"
	s ^x=x
	s x="bar"
	s ^y=x
	tcommit
	q
