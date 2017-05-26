VV1DOC44	;VV1DOC V.7.1 -44-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-313. expr is numeric literal with leading zero
	;       I-313.1  002
	;       I-313.2  0000000000000099.12
	;     I-314. expr is decimal with following zero
	;       I-314.1  3.110000000000000000
	;       I-314.2  3.1100000000000E-00002
	;       I-314.3  -00000000000000.0000000000000
	;
	;
	;$PIECE FUNCTION -1-
	;     (V1FNP1)
	;
	;     $PIECE(expr1, expr2, intexpr3)
	;
	;     I-315. Substring specified by intexpr3 exist in expr1
	;       I-315.1  intexpr3=1
	;       I-315.2  intexpr3=2
	;       I-315.3  intexpr3=3
	;       I-315.4  intexpr3=4
	;       I-315.5  expr1 contains unary operator
	;     I-316. Substring specified by intexpr3 does not exist in expr1
	;       I-316.1  intexpr3=1
	;       I-316.2  intexpr3>$L(expr1)
	;     I-317. intexpr3<0
	;     I-318. intexpr3=0
	;     I-319. intexpr3>$LENGTH(expr1)
	;     I-320. $LENGTH(expr1)<$LENGTH(expr2)
	;       I-320.1  intexpr3=1
	;       I-320.2  intexpr3=2
	;     I-321. expr1=expr2
	;     I-322. intexpr3>255
	;     I-323. intexpr3 is non-integer numeric
	;       I-323.1  3.9999
	;       I-323.2  3.49999
	;     I-324. Control characters are used as delimiters (expr2)
	;
	;
	;$PIECE FUNCTION -2-
	;     (V1FNP2)
	;
	;     I-325. expr1 is non-integer numeric literal
	;     I-326. expr1 is empty string
	;     I-327. expr2 is empty string
	;     I-328. Both expr1 and expr2 are empty strings
	;     I-329. expr2 is numeric literal
