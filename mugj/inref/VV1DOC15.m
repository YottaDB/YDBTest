VV1DOC15	;VV1DOC V.7.1 -15-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;         I-799.5.6  "mantEintlit"
	;         I-799.5.7  "mantE+intlit"
	;         I-799.5.8  "mantE-intlit"
	;
	;
	;Unary operators -5-
	;     (V1UO3A)
	;
	;     I-800. not unary operator
	;       I-800.1  not unary operator and a numlit
	;         I-800.1.1  '0
	;         I-800.1.2  '1
	;         I-800.1.3  'intlit
	;         I-800.1.4  '.intlit
	;         I-800.1.5  'intlit.intlit
	;         I-800.1.6  'mantEintlit
	;         I-800.1.7  'mantE+intlit
	;         I-800.1.8  'mantE-intlit
	;       I-800.2  not unary operator and a strlit
	;         I-800.2.1  '"0"
	;         I-800.2.2  '"1"
	;         I-800.2.3  'intlit
	;         I-800.2.4  '.intlit
	;         I-800.2.5  'intlit.intlit
	;         I-800.2.6  'mantEintlit
	;         I-800.2.7  'mantE+intlit
	;         I-800.2.8  'mantE-intlit
	;         I-800.2.9  'empty string
	;         I-800.2.10  '"AB2"
	;         I-800.2.11  '"2A2B"
	;
	;
	;Unary operators -6-
	;     (V1UO3B)
	;
	;       I-800.3  not unary operator and a strlit
	;         I-800.3.1  '"+0"
	;         I-800.3.2  '"+1"
	;         I-800.3.3  'intlit
	;         I-800.3.4  '.intlit
	;         I-800.3.5  'intlit.intlit
	;         I-800.3.6  'mantEintlit
	;         I-800.3.7  'mantE+intlit
	;         I-800.3.8  'mantE-intlit
	;         I-800.3.9  '"-AB2"
