VV1DOC13	;VV1DOC V.7.1 -13-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Unary operators -2-
	;     (V1UO1B)
	;
	;       I-798.3  plus unary operator and a strlit contains plus operator
	;         I-798.3.1  +"+0"
	;         I-798.3.2  +"+1"
	;         I-798.3.3  +strlit
	;         I-798.3.4  +".intlit"
	;         I-798.3.5  +"intlit.intlit"
	;         I-798.3.6  +"mantEintlit"
	;         I-798.3.7  +"mantE+intlit"
	;         I-798.3.8  +"mantE-intlit"
	;         I-798.3.9  +"+AB2"
	;         I-798.3.10  +"+2A2B"
	;       I-798.4  plus unary operator and a lvn
	;         I-798.4.1  0
	;         I-798.4.2  1
	;         I-798.4.3  intlit
	;         I-798.4.4  .intlit
	;         I-798.4.5  intlit.intlit
	;         I-798.4.6  mantEintlit
	;         I-798.4.7  mantE+intlit
	;         I-798.4.8  mantE-intlit
	;       I-798.5  plus unary operator and a lvn
	;         I-798.5.1  "0"
	;         I-798.5.2  "1"
	;         I-798.5.3  "intlit"
	;         I-798.5.4  ".intlit"
	;         I-798.5.5  "intlit.intlit"
	;         I-798.5.6  "mantEintlit"
	;         I-798.5.7  "mantE+intlit"
	;         I-798.5.8  "mantE-intlit"
	;
	;
	;Unary operators -3-
	;     (V1UO2A)
	;
	;     I-799. negate unary operator
	;       I-799.1  negate unary operator and a numlit
	;         I-799.1.1  -0
	;         I-799.1.2  -1
	;         I-799.1.3  -intlit
	;         I-799.1.4  -.intlit
	;         I-799.1.5  -intlit.intlit
	;         I-799.1.6  -mantEintlit
