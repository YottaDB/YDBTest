VV2DOC4	;VV2DOC V.7.1 -4-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     II-68. $t
	;
	;
	;Functions extended -1-
	;     (VV2FN1)
	;
	;     $DATA(glvn)
	;
	;     II-69. Effect of local variable descendant KILL
	;     II-70. Effect of global variable descendant KILL
	;
	;     $EXTRACT(expr) with one argument
	;
	;     II-71. expr is strlit
	;     II-72. expr is 255 characters
	;     II-73. expr is empty string
	;     II-74. expr is numeric literal
	;
	;     $FIND(expr1,expr2,intexpr3)
	;
	;     II-75. intexpr3<0 and expr1 is strlit
	;     II-76. intexpr3<0 and expr1 is variable
	;
	;     $JUSTIFY(numexpr1,intexpr2,intexpr3)
	;
	;     II-77. 0<numexpr1<1
	;     II-78. -1<numexpr1<0
	;
	;     $PIECE(expr1,expr2)
	;
	;     II-91. expr1 and expr2 are strlits
	;     II-92. expr2 is empty string
	;     II-93. expr1 is empty string
	;     II-94. expr1 and expr2 are variables
	;
	;
	;Functions extended -1-
	;     (VV2FN1)
	;
	;     $LENGTH(expr1,expr2)
	;
	;     II-79. expr1 and expr2 are string literals
	;     II-80. expr2 is empty string
	;     II-81. $L(expr1)<$L(expr2)
	;     II-82. $L(expr1,expr2)=3
