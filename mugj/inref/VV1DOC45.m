VV1DOC45	;VV1DOC V.7.1 -45-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-330. expr2 contains operators
	;       I-330.1  concatenation operator
	;       I-330.2  another concatenation operator
	;       I-330.3  + binary operators
	;
	;     $PIECE(expr1, expr2, intexpr3, intexpr4)
	;
	;     I-331. intexpr4 is positive integer
	;       I-331.1  intexpr3<intexpr4
	;       I-331.2  expr1 is intlit
	;       I-331.3  intexpr3<-1
	;       I-331.4  intexpr4>$L(expr1)
	;       I-331.5  $F(expr1,expr2)=0
	;       I-331.6  expr1 contains _ binary operator
	;       I-331.7  expr1 is empty string
	;       I-331.8  expr2 is empty string
	;       I-331.9  expr1 and expr2 are empty string
	;     I-332. intexpr4 is non-integer
	;       I-332.1  2.5
	;       I-332.2  02.4560000
	;     I-333. intexpr3>intexpr4
	;     I-334. intexpr4>255
	;
	;
	;$CHAR and $ASCII -1-
	;     (V1AC1)
	;
	;     $CHAR(L intexpr)
	;
	;     I-1. intexpr is checked for 32-126
	;     I-2. L intexpr is checked for 32-126
	;
	;     Control characters
	;
	;       It may have  wrong effect on format or  terminal attributes to
	;       write control characters on the terminal. And it is impossible
	;       to determine whether or not the value of $CHAR is correct.
	;       Accordingly control characters, which are 0-31 in ASCII code,
	;       are not checked here.
	;
	;     I-3. Integer interpretation of intexpr, while intexpr is string literal
	;     I-4. Integer interpretation of intexpr, while intexpr is numeric literal
	;     I-5. Integer interpretation of intexpr, while intexpr contains binaryop
	;     I-6. intexpr < 0
	;     I-7. The difference between $CHAR(0) and empty string
