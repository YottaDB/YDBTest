VV1DOC42	;VV1DOC V.7.1 -42-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-291.1  expr1 is numlit
	;       I-291.2  expr1 is another numlit
	;     I-292. expr1 contains more than one expr2's
	;       I-292.1  $L(expr2)>1
	;       I-292.2  another
	;       I-292.3  $L(expr2)=1
	;     I-293. expr1 is non-integer numeric and expr2 is "." or "-"
	;       I-293.1  expr1 is mant
	;       I-293.2  expr1 is mant exp
	;       I-293.3  expr1 is negative non-integer numlit
	;     I-294. expr1 is empty string
	;       I-294.1  expr1 is strlit
	;       I-294.2  expr1 is lvn
	;     I-295. expr2 is empty string
	;       I-295.1  expr2 is strlit
	;       I-295.2  expr2 is lvn
	;     I-296. Both expr1 and expr2 are empty string
	;       I-296.1  Both expr1 and expr2 are strlit
	;       I-296.2  Both expr1 and expr2 are lvn
	;     I-847. $F(expr1,expr2)=256  ;boundary
	;       I-847.1  $F=255
	;       I-847.2  $F=256
	;
	;
	;$FIND FUNCTION -3-
	;     (V1FNF3)
	;
	;     $FIND(expr1, expr2, intexpr3)
	;
	;     I-297. intexpr3<0
	;       I-297.1  expr1 contains expr2
	;       I-297.2  expr2 is empty string
	;       I-297.3  expr1 and expr2 are empty string
	;       I-297.4  expr1 is empty string
	;     I-298. intexpr3=0
	;       I-298.1  $L(expr1)>$L(expr2)
	;       I-298.2  $L(expr1)<$L(expr2)
	;       I-298.3  expr2 is empty string
	;       I-298.4  expr1 and expr2 are empty string
	;       I-298.5  expr1 is empty string
	;     I-299. 0<intexpr3 and intexpr3'>$LENGTH(expr1)
	;       I-299.1  intexpr3=1
	;       I-299.2  $E(expr1,intexpr3,intexpr3+$L(expr2)-1)=expr2
	;       I-299.3  intexpr3=$L(expr1)
	;       I-299.4  expr2 is empty string
