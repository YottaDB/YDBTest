VV1DOC24	;VV1DOC V.7.1 -24-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-60.2  "2A2B"\"2E2B"
	;     I-61. expratoms are lvn
	;       I-61.1  unsubscripted lvn
	;       I-61.2  subscripted lvn
	;
	;
	;Binary operators -1.6- (+, -, *, /, #, \(integer division))
	;     (V1BOA6)
	;
	;     the left argument modulo the right argument
	;
	;     I-62. expratom=0
	;       I-62.1  0#4
	;       I-62.2  0#-4
	;     I-63. left expratom>0, right expratom>0
	;       I-63.1  1#4
	;       I-63.2  2#4
	;       I-63.3  3#4
	;       I-63.4  4#4
	;       I-63.5  5#4
	;       I-63.6  6#4
	;       I-63.7  7#4
	;       I-63.8  8#4
	;       I-63.9  0.5#.5
	;       I-63.10  4.1#.01
	;     I-64. left expratom>0, right expratom<0
	;       I-64.1  1#-4
	;       I-64.2  2#-4
	;       I-64.3  3#-4
	;       I-64.4  4#-4
	;       I-64.5  5#-4
	;       I-64.6  6#-4
	;       I-64.7  7#-4
	;       I-64.8  8#-4
	;       I-64.9  0.3#-.3
	;     I-65. left expratom<0, right expratom>0
	;       I-65.1  -1#4
	;       I-65.2  -2#4
	;       I-65.3  -3#4
	;       I-65.4  -4#4
	;       I-65.5  -5#4
	;       I-65.6  -6#4
	;       I-65.7  -7#4
	;       I-65.8  -8#4
	;       I-65.9  -597.5#25
