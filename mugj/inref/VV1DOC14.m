VV1DOC14	;VV1DOC V.7.1 -14-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;         I-799.1.7  -mantE+intlit
	;         I-799.1.8  -mantE-intlit
	;       I-799.2  negate unary operator and a strlit
	;         I-799.2.1  -"0"
	;         I-799.2.2  -"1"
	;         I-799.2.3  -strlit
	;         I-799.2.4  -.intlit
	;         I-799.2.5  -intlit.intlit
	;         I-799.2.6  -mantEintlit
	;         I-799.2.7  -mantE+intlit
	;         I-799.2.8  -mantE-intlit
	;         I-799.2.9  -empty string
	;         I-799.2.10  -"AB2"
	;         I-799.2.11  -"2A2B"
	;
	;
	;Unary operators -4-
	;     (V1UO2B)
	;
	;       I-799.3  negate unary operator and a strlit
	;         I-799.3.1  -"-0"
	;         I-799.3.2  -"-1"
	;         I-799.3.3  -"+intlit"
	;         I-799.3.4  -"-.intlit"
	;         I-799.3.5  -"-intlit.intlit"
	;         I-799.3.6  -"-mantEintlit"
	;         I-799.3.7  -"-mantE+intlit"
	;         I-799.3.8  -"-mantE-intlit"
	;         I-799.3.9  -"-AB2"
	;         I-799.3.10  -"-2A2B"
	;       I-799.4  negate unary operator and a lvn
	;         I-799.4.1  0
	;         I-799.4.2  1
	;         I-799.4.3  intlit
	;         I-799.4.4  .intlit
	;         I-799.4.5  intlit.intlit
	;         I-799.4.6  mantEintlit
	;         I-799.4.7  mantE+intlit
	;         I-799.4.8  mantE-intlit
	;       I-799.5  negate unary operator and a lvn
	;         I-799.5.1  "0"
	;         I-799.5.2  "1"
	;         I-799.5.3  "intlit"
	;         I-799.5.4  ".intlit"
	;         I-799.5.5  "intlit.intlit"
