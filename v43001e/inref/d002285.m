d002285	;
	; the driver script does ZSTEP OVER thrice.
	; due to the bug described in the TR, a ZSTEP OVER used not to break because of OC_HARDRET being generated
	;
	write "---------------------------------------------------------------------------------",!
	write "You should see one GTM-I-BREAK followed by two GTM-I-BREAKZST lines in the output",!
	write "---------------------------------------------------------------------------------",!
	break
	do ^d002285a
	quit
