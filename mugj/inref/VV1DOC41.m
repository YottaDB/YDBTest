VV1DOC41	;VV1DOC V.7.1 -41-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-283.2  intexpr2>1 and intexpr3<-1
	;     I-284. intexpr3>$LENGTH(expr1)
	;       I-284.1  intexpr2=1
	;       I-284.2  1<intexpr2<$L(expr1)
	;       I-284.3  expr1 contains unary operator
	;       I-284.4  intexpr2<-1
	;     I-285. intexpr3>intexpr2>$LENGTH(expr1)
	;     I-286. intexpr2>$LENGTH(expr1) and intexpr3<0
	;
	;
	;$FIND FUNCTION -1-
	;     (V1FNF1)
	;
	;     $FIND(expr1, expr2)
	;
	;     I-287. expr1 is string literal and contains expr2
	;       I-287.1  $L(expr2)=1
	;       I-287.2  $L(expr2)=2
	;       I-287.3  expr1=expr2
	;       I-287.4  $L(expr1,expr2)=2 and $E(expr1,1,$L(expr2))=expr2
	;       I-287.5  $L(expr1,expr2)>2 and $E(expr1,1,$L(expr2))=expr2
	;       I-287.6  $E(expr1,$L(expr1)-$L(expr2)+1,$L(expr1))=expr2
	;       I-287.7  $L(expr1,expr2)=2 and $E(expr1,1,$L(expr2))'=expr2
	;       I-287.8  $L(expr1,expr2)>2 and $E(expr1,1,$L(expr2))'=expr2
	;       I-287.9  expr2 is "."
	;     I-288. expr1 is numeric literal and contains expr2
	;       I-288.1  expr1 is numlit
	;       I-288.2  expr1 is another numlit
	;     I-289. expr1 is string literal and does not contains expr2
	;       I-289.1  expr1 does not contains expr2 character
	;       I-289.2  expr2 is lvn
	;       I-289.3  $L(expr1)=$L(expr2) and expr1'=expr2
	;       I-289.4  $L(expr1)<$L(expr2)
	;       I-289.5  $L(expr1,$E(expr2,1,$L(expr2)-1))>1
	;       I-289.6  $L(expr1,$E(expr2,2,$L(expr2)))>1
	;       I-289.7  $L(expr1,$E(expr2,2,$L(expr2)-1))>1
	;
	;
	;$FIND FUNCTION -2-
	;     (V1FNF2)
	;
	;     I-290. expr1 is numeric literal and does not contains expr2
	;       I-290.1  expr1 is numlit
	;       I-290.2  expr1 is another numlit
	;     I-291. expr1 is non-integer numeric literal
