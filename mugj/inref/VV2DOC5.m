VV2DOC5	;VV2DOC V.7.1 -5-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     II-83. $L(expr1,expr2)=2
	;     II-84. expr1 and expr2 are empty strings
	;     II-85. expr1 is empty string
	;     II-86. $L(expr1,expr2)=1
	;     II-87. expr1 and expr2 are variables
	;     II-88. $L(expr1,expr2)=256
	;     II-89. expr2 is control character
	;     II-90. expr1 is numeric literal
	;
	;     $TEXT(+intexpr)
	;
	;     II-95. intexpr=0
	;        II-95.1  intexpr=0
	;        II-95.2  ls is multi spaces
	;
	;
	;Left hand $PIECE -1-
	;     (VV2LHP1)
	;
	;     $PIECE(glvn,expr1)
	;
	;     II-96. expr1 is string literal
	;
	;     $PIECE(glvn,expr1,intexpr2)
	;
	;     II-97. expr1 is string literal
	;
	;     $PIECE(glvn,expr1,intexpr2,intexpr3)
	;      K=max(0,$L(glvn,expr1)-1)
	;
	;     II-98. intexpr2>intexpr3
	;     II-99. intexpr3<1
	;        II-99.1  intexpr2=1
	;        II-99.2  intexpr2<intexpr3
	;        II-99.3  intexpr2>intexpr3
	;     II-100. K<intexpr2-1<intexpr3
	;        II-100.1  K=0
	;        II-100.2  K=1
	;        II-100.3  K=2
	;     II-101. intexpr2-1<=K<intexpr3
	;        II-101.1  K=0
	;        II-101.2  K=1
	;        II-101.3  K=2
	;     II-102. intexpr2-1<intexpr3<=K
	;        II-102.1  K=1
