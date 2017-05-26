VV1DOC68	;VV1DOC V.7.1 -68-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-562.2  "-"_"0012"
	;     I-563. expr1 contains unary operator
	;     I-564. expr1 contains function
	;       I-564.1  $LENGTH
	;       I-564.2  $JUSTIFY
	;     I-565. expr1 contains gvn
	;     I-566. intexpr2>0
	;     I-567. intexpr2=0
	;     I-568. intexpr2<0
	;     I-569. intexpr2<$L(expr1)
	;       I-569.1  intexpr2=1
	;       I-569.2  intexpr2=($L(expr1)+1)
	;     I-570. intexpr2=$L(expr1)
	;     I-571. intexpr2>$L(expr1)
	;
	;
	;$JUSTIFY, $SELECT, $TEXT -2-
	;     (V1JST2)
	;
	;     $JUSTIFY(numexpr1, intexpr2, intexpr3)
	;
	;     I-572. numexpr1 is empty string
	;       I-572.1  intexpr3=1
	;       I-572.2  intexpr3>1
	;     I-573. numexpr1 is positive non-integer numeric
	;     I-574. numexpr1 is negative non-integer numeric
	;       I-574.1  intexpr3=2
	;       I-574.2  intexpr3=1
	;       I-574.3  intexpr3=0
	;       I-574.4  intexpr3=0 another
	;     I-575. absolute value of numexpr1 is greater than 0 and less than 1
	;       I-575.1  numexpr1>0
	;       I-575.2  numexpr1<0
	;     I-576. numexpr1 is mant exp
	;       I-576.1  -0.0099E1
	;       I-576.2  -1.0099E-1
	;       I-576.3  000.004567E+7
	;     I-577. intexpr2<0
	;     I-578. intexpr2=0
	;     I-579. intexpr2>0 and intexpr3>0
	;     I-580. intexpr2<0 and intexpr3=0
	;     I-581. intexpr2<0 and intexpr3<0
	;            ( This test I-581 was nullified in 1984 ANSI, MSL )
	;     I-582. intexpr2>intexpr3
	;     I-583. intexpr2=intexpr3
