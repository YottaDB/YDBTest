pat	; Check a couple of patterns to match (D9B05-001858)
	s RES="AAA1111-1111AAAAA"
	; the two expressions below are equivalent, but the first one causes a SIG11 (V42002)
	d match
	s RES="A11-1A"
	d match
	w "PASSED",!
	q
match	;
	w RES?.E1N.N1"-"1N.N.E 	
	w !
	w RES?.E1N.N1"-"1N.E
	w !
	q
