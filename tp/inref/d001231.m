trd1231 ;
	;	Test case for TR entry : D9905-001231
	;
	; assumes "^a" is mapped to a different region than "^b"
	;
	s ^b=1
	s ^a=1
	tstart ():serial  d
	.	s ^a=1
	.	s ^b=1
	.	tstart ():serial  d
	.	.	if $trestart=0 trestart
	.	tcommit
	tcommit
	q
