VV1DOC12	;VV1DOC V.7.1 -12-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-253. Effect of comment delimiter on format
	;
	;     Tab operation  ?intexpr
	;
	;     I-254. intexpr is positive integer
	;     I-255. intexpr is zero
	;     I-256. intexpr less than zero
	;
	;
	;Format control characters -2-
	;     (V1FC2)
	;
	;     I-257. intexpr is non-integer numeric literal
	;     I-258. intexpr contains binary operator
	;     I-259. intexpr contains unary operator
	;     I-260. intexpr is function
	;     I-261. intexpr is variable name
	;     I-262. intexpr is greater than $X
	;
	;
	;Unary operators -1-
	;     (V1UO1A)
	;
	;     I-798. plus unary operator
	;       I-798.1. plus unary operator and a numlit
	;         I-798.1.1  +0
	;         I-798.1.2  +1
	;         I-798.1.3  +intlit
	;         I-798.1.4  +.intlit
	;         I-798.1.5  +intlit.intlit
	;         I-798.1.6  +mantEintlit
	;         I-798.1.7  +mantE+intlit
	;         I-798.1.8  +mantE-intlit
	;       I-798.2  plus unary operator and a strlit
	;         I-798.2.1  +"0"
	;         I-798.2.2  +"1"
	;         I-798.2.3  +strlit
	;         I-798.2.4  +.intlit
	;         I-798.2.5  +intlit.intlit
	;         I-798.2.6  +mantEintlit
	;         I-798.2.7  +mantE+intlit
	;         I-798.2.8  +mantE-intlit
	;         I-798.2.9  +empty string
	;         I-798.2.10  +"AB2"
	;         I-798.2.11  +"2A2B"
