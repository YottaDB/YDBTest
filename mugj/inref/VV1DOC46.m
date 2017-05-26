VV1DOC46	;VV1DOC V.7.1 -46-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-7.1  empty string
	;       I-7.2  $LENGTH
	;       I-7.3  value of $A
	;
	;
	;$CHAR and $ASCII -2-
	;     (V1AC2)
	;
	;     $ASCII(expr)
	;
	;     I-8. expr is string literal, and $L(expr)=0
	;          i.e. expr is empty string 
	;     I-9. expr is string literal, and $L(expr)=1
	;     I-10. expr is string literal, and $L(expr)>0
	;     I-11. expr is numeric literal, and $L(expr)=1
	;           i.e. expr is a digit
	;     I-12. expr is numeric literal, and $L(expr)>1,expr<0
	;     I-13. expr is numeric literal, and $L(expr)>1,expr<=0
	;     I-14. expr is $CHAR corresponding to ASCII code 0-127
	;       I-14.1  0-31
	;       I-14.2  32-94
	;       I-14.3  95-127
	;       I-14.4  expr is lvn
	;
	;     $ASCII(expr1,intexpr2)
	;
	;     I-15. expr1 is string literal
	;     I-16. expr1 is non-integer numeric literal, and greater than zero
	;     I-17. expr1 is non-integer numeric literal, and less than zero
	;     I-18. expr1 is integer numeric literal, and greater than zero
	;     I-19. expr1 is integer numeric literal, and less than zero
	;     I-20. intexpr2 is less than zero
	;     I-21. intexpr2 is greater than $LENGTH(expr1)
	;       I-20/21.1  intexpr2 is less than zero
	;       I-20/21.2  intexpr2 is greater than $L(expr1)
	;       I-20/21.3  expr1 is strlit
	;       I-20/21.4  expr1 is non-integer literal
	;
	;
	;Local variable name
	;     (V1LVN)
	;
	;     I-611. lvn is "%"
	;     I-612. lvn is "%" and alpha
	;     I-613. lvn is "%" and digit
