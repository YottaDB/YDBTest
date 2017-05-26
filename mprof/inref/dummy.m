	w "DUMMY",!
	; no label here
	s dummy=0
	; still none
dum	s dummy=1
	f i=1:1:10 s dummy=dummy-1 f j=1:1:1001 s dummy=dummy+1
	;comment
	;more comments
	q
