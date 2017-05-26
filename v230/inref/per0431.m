per0431	;PER0431 - $T or ZP of a line with <SP>s after the LS truncates the line
	;
	w !,$t(T),!
	zp ZP
	q
T                 ;OK from $T of a line with <SP>s after the LS
ZP                ;OK from ZP of a line with <SP>s after the LS
