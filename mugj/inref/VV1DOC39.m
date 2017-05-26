VV1DOC39	;VV1DOC V.7.1 -39-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Logical operator -3.3- (!,&) and concatenation operator (_)
	;     (V1BOC2)
	;
	;     Concatenation  (_)
	;
	;     I-160. expratoms are strlit
	;       I-160.1  "A"_"B"
	;       I-160.2  "#"_"%"
	;       I-160.3  "000"_"010"
	;       I-160.4  "_""_"_"zxcv"
	;     I-161. expratoms are numlit
	;       I-161.1  2_3
	;       I-161.2  000.000_3.4
	;       I-161.3  3E1_-.5E1
	;     I-162. relation with unary operator
	;       I-162.1  '0_''0
	;       I-162.2  000.000_+"3.4E2"
	;     I-163. more than one concatenation in one expr
	;     I-164. expratoms are lvn
	;       I-164.1  A_B
	;       I-164.2  B_C_"ABD"_D
	;       I-164.3  C_D
	;       I-164.4  A_-D
	;       I-164.5  A(29)_B(0,20)
	;
	;
	;$EXTRACT FUNCTION -1-
	;     (V1FNE1)
	;
	;     $EXTRACT(expr1, intexpr2)
	;
	;     I-263. expr1 is string literal
	;     I-264. expr1 is positive integer
	;     I-265. expr1 is negative integer
	;       I-265.1  -000789400
	;       I-265.2  -00789400
	;     I-266. expr1 is non-integer numeric literal
	;       I-266.1  0007.89400
	;       I-266.2  -000723.89400E-01
	;       I-266.3  0000723.8900E04
	;       I-266.4  -0000.00E04
	;     I-267. expr1 is function
	;       I-267.1  $EXTRACT(expr1,intexpr2)
	;       I-267.2  $E(expr1,intexpr2,intexpr3)
	;     I-268. expr1 contains unary operator
