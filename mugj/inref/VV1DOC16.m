VV1DOC16	;VV1DOC V.7.1 -16-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;         I-800.3.10  '"-2A2B"
	;       I-800.4  not unary operator and a lvn
	;         I-800.4.1  '0
	;         I-800.4.2  '1
	;         I-800.4.3  'intlit
	;         I-800.4.4  '.intlit
	;         I-800.4.5  'intlit.intlit
	;         I-800.4.6  'mantEintlit
	;         I-800.4.7  'mantE+intlit
	;         I-800.4.8  'mantE-intlit
	;       I-800.5  not unary operator and a lvn
	;         I-800.5.1  "0"
	;         I-800.5.2  "1"
	;         I-800.5.3  "intlit"
	;         I-800.5.4  ".intlit"
	;         I-800.5.5  "intlit.intlit"
	;         I-800.5.6  "mantEintlit"
	;         I-800.5.7  "mantE+intlit"
	;         I-800.5.8  "mantE-intlit"
	;
	;
	;Unary operators -7-
	;     (V1UO4A)
	;
	;     I-801. multi unary operators
	;       I-801.1  duplicate unary operators and a numlit
	;         I-801.1.1  ++0
	;         I-801.1.2  +-0
	;         I-801.1.3  +'0
	;         I-801.1.4  -+0
	;         I-801.1.5  --0
	;         I-801.1.6  -'0
	;         I-801.1.7  '+0
	;         I-801.1.8  '-0
	;         I-801.1.9  ''0
	;         I-801.1.10  ++intlit
	;         I-801.1.11  +-intlit
	;         I-801.1.12  +'intlit
	;         I-801.1.13  -+intlit
	;         I-801.1.14  --intlit
	;         I-801.1.15  -'intlit
	;         I-801.1.16  '+intlit
	;         I-801.1.17  '-intlit
	;         I-801.1.18  ''intlit
	;
