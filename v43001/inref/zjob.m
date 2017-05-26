zjob(k)	; test speed of various increment operations
	l +^x ; to wait till parent sets ^zjobs(k)
	s ^zjout(k)="Jobbed off process ("_$j_"): "
	i ^zjobs(k)'=$j s ^zjout(k)=^zjout(k)_"FAILED: does not match with "_^zjobs(k)
	e  s ^zjout(k)=^zjout(k)_"PASSED:"
	l -^x
	s ^zjout(0)=1 ; to notify parent end of the job
	q

