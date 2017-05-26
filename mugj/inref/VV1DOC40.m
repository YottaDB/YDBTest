VV1DOC40	;VV1DOC V.7.1 -40-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-268.1  + unary operator
	;       I-268.2  expr1 is + lvn
	;     I-269. expr1 contains binary operator
	;       I-269.1  + binary operator
	;       I-269.2  - binary operator
	;       I-269.3  + and / binary operators
	;     I-270. expr1 is empty string
	;     I-271. intexpr2 is string literal
	;       I-271.1  intexpr2="A3BCD"
	;       I-271.2  intexpr2="3.6BCD"
	;     I-272. intexpr2 is positive integer
	;     I-273. intexpr2 is negative integer
	;     I-274. intexpr2 is zero
	;     I-275. intexpr2>$LENGTH(expr1)
	;       I-275.1  (intexpr2+1)=$L(expr1)
	;       I-275.2  intexpr2>255
	;     I-276. intexpr2 is non-integer numeric literal
	;     I-277. intexpr2 is function
	;     I-278. intexpr2 is lvn
	;     I-279. intexpr2 contains unary operator
	;     I-280. intexpr2 contains binary operator
	;
	;
	;$EXTRACT FUNCTION -2-
	;     (V1FNE2)
	;
	;     $EXTRACT(expr1, intexpr2, intexpr3)
	;
	;     I-281. intexpr2<intexpr3
	;       I-281.1  intexpr3<$L(expr1)
	;       I-281.2  intexpr contains lvn
	;       I-281.3  intexpr3>$L(expr1)
	;       I-281.4  intexpr2<0
	;       I-281.5  intexpr2<0 and intexpr3>$L(expr1)
	;       I-281.6  expr1 is function
	;     I-282. intexpr2=intexpr3
	;       I-282.1  intexpr=1
	;       I-282.2  1<intexpr<$L(expr1)
	;       I-282.3  intexpr=$L(expr1)
	;       I-282.4  intexpr=0
	;       I-282.5  intexpr<-1
	;       I-282.6  intexpr>$L(expr1)
	;       I-282.7  expr1 is empty string and intexpr=1
	;     I-283. intexpr2>intexpr3
	;       I-283.1  intexpr3>0
