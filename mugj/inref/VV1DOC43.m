VV1DOC43	;VV1DOC V.7.1 -43-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-300. intexpr3>$LENGTH(expr1)
	;       I-300.1  $L(expr1)>$L(expr2)>1
	;       I-300.2  expr2 is empty string
	;       I-300.3  expr2 is empty string and intexpr3>255
	;       I-300.4  expr1 and expr2 are empty string
	;     I-301. expr1 contains more than one expr2's and intexpr3'>$FIND(expr1,expr2)
	;     I-302. expr1 contains more than one expr2's and intexpr3>$FIND(expr1,expr2)
	;
	;
	;$LENGTH FUNCTION
	;     (V1FNL)
	;
	;     $LENGTH(expr)
	;
	;     I-303. expr is string literal
	;       I-303.1  all 95 ASCII printable character, including SP
	;       I-303.2  "002"
	;       I-303.3  strlit contains " character
	;       I-303.4  $L(expr)=256
	;     I-304. expr is empty string
	;     I-305. expr is control character
	;       I-305.1  one control character
	;       I-305.2  all control characters
	;     I-306. expr contains operator
	;       I-306.1  + unary operator
	;       I-306.2  + binary operator
	;       I-306.3  _ binary operator
	;     I-307. expr contains function
	;     I-308. expr is integer
	;       I-308.1  123
	;       I-308.2  0
	;       I-308.3  -0.0
	;     I-309. expr is non-integer
	;       I-309.1  3000.11
	;       I-309.2  00030.011000
	;     I-310. expr is negative numeric
	;       I-310.1  -123
	;       I-310.2  -123000
	;       I-310.3  -9.86056000
	;       I-310.4  -000.0110
	;     I-311. 0<expr<1
	;     I-312. expr is numeric represented by scientific notation
	;       I-312.1  -1E3
	;       I-312.2  000001.0000E-6
	;       I-312.3  98765E-3
