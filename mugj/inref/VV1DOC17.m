VV1DOC17	;VV1DOC V.7.1 -17-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Unary operators -8-
	;     (V1UO4B)
	;
	;       I-801.2  triplicate unary operators and a numlit
	;         I-801.2.1  +++numlit
	;         I-801.2.2  ++-numlit
	;         I-801.2.3  ++'numlit
	;         I-801.2.4  +-+numlit
	;         I-801.2.5  +--numlit
	;         I-801.2.6  +-'numlit
	;         I-801.2.7  +'+numlit
	;         I-801.2.8  +'-numlit
	;         I-801.2.9  +''numlit
	;         I-801.2.10  -++numlit
	;         I-801.2.11  -+-numlit
	;         I-801.2.12  -+'numlit
	;         I-801.2.13  --+numlit
	;         I-801.2.14  ---numlit
	;         I-801.2.15  --'numlit
	;         I-801.2.16  -'+numlit
	;         I-801.2.17  -'-numlit
	;         I-801.2.18  -''numlit
	;         I-801.2.19  '++numlit
	;         I-801.2.20  '+-numlit
	;         I-801.2.21  '+'numlit
	;         I-801.2.22  '-+numlit
	;         I-801.2.23  '--numlit
	;         I-801.2.24  '-'numlit
	;         I-801.2.25  ''+numlit
	;         I-801.2.26  ''-numlit
	;         I-801.2.27  '''numlit
	;       I-801.3  multiple unary operators and a numlit
	;         I-801.3.1  -'+'-'+'-numlit
	;         I-801.3.2  +'-'+'-'+numlit
	;         I-801.3.3  +--''+'-numlit
	;
	;
	;Unary operators -9-
	;     (V1UO5A)
	;
	;       I-801.4  duplicate unary operators and a strlit
	;         I-801.4.1  ++"0"
	;         I-801.4.2  +-"0"
	;         I-801.4.3  +'"0"
	;         I-801.4.4  -+"0"
