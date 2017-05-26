c001583	; Generated an assert failure in V4.2-FT03 (C9A08-001583)
	s x="123456|||||||||||||||||||||||||||||||||||||||||||||||||||"
	s y=$P(x,"|",2)
	s x=+x
	s $P(x,"|",2)="abc"
	Write "Pass from c001583"
	Q
