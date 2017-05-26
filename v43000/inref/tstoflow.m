; Check that a stack overflow does NOT produce a core. Output will
; be same in either case but test system should detect core if one
; is created.

tstoflow	;
	Write "tstoflow starting",!	
	s $ZT="Do B"
	s i=0
	d A
	Q
A	s i=i+1
	d A
	Q
B	s i=i+1
	W $ZSTATUS,!
	d A
	Q
