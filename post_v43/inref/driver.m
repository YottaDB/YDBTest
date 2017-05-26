driver	; 
	; test case to check NOISOLATION doesn't recompute updates on out-of-date buffer
	; test requires just one database (where ^ZNOISO is mapped) with no other requirements.
	;
	k ^ZNOISO
	d ^job("d002016",5,"""""")	; spawn off 5 children each of them doing the same thing
	q
