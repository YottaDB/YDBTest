d002592	;
	; D9G01-002592 MUPIP LOAD arbitrarily low record limit impedes large ZWR loads
	;
	set ^y(1)=$j(1,5)
	f i=1:1:10 s ^x(i)=$j(i,400)
	quit
