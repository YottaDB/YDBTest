VV1DOC18	;VV1DOC V.7.1 -18-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;         I-801.4.5  --"0"
	;         I-801.4.6  -'"0"
	;         I-801.4.7  '+"0"
	;         I-801.4.8  '-"0"
	;         I-801.4.9  ''"0"
	;         I-801.4.10  ++strlit
	;         I-801.4.11  +-strlit
	;         I-801.4.12  +'strlit
	;         I-801.4.13  -+strlit
	;         I-801.4.14  --strlit
	;         I-801.4.15  -'strlit
	;         I-801.4.16  '+strlit
	;         I-801.4.17  '-strlit
	;         I-801.4.18  ''strlit
	;       I-801.5  duplicate unary operators and a strlit with a unary operator
	;         I-801.5.1  ++"+0"
	;         I-801.5.2  +-"-0"
	;         I-801.5.3  +'"-0"
	;         I-801.5.4  -+"+0"
	;         I-801.5.5  --"-0"
	;         I-801.5.6  -'"+0"
	;         I-801.5.7  '+"-0"
	;         I-801.5.8  '-"+0"
	;         I-801.5.9  ''"+0"
	;         I-801.5.10  ++strlit
	;         I-801.5.11  +-strlit
	;         I-801.5.12  +'strlit
	;         I-801.5.13  -+strlit
	;         I-801.5.14  --strlit
	;         I-801.5.15  -'strlit
	;         I-801.5.16  '+strlit
	;         I-801.5.17  '-strlit
	;         I-801.5.18  ''strlit
	;
	;
	;Unary operators -10-
	;     (V1UO5B)
	;
	;       I-801.6  unary operator(s) and a strlit
	;         I-801.6.1  -"+-2"
	;         I-801.6.2  '"+++2"
	;         I-801.6.3  -"-+-2"
	;         I-801.6.4  ++--+-"+-+.20E+01.5"
	;       I-801.7  duplicate unary operators and a lvn
	;         I-801.7.1  ++lvn (lvn=0)
