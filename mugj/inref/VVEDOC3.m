VVEDOC3	;VVEDOC V.7.1 -3-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;P.I-22   $TEXT 
	;     (VVETEXT)
	;
	;     III-4  P.I-22 I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)
	;            An error will occur if the value of intexpr is less than 0.
	;       III-4.1  $TEXT(+-1)
	;       III-4.2  S A=$T(+-999999999)
	;       III-4.3  $T(TEXT+2-3)
	;       III-4.4  S A="TEXT",B=-300 W $T(@A+B)
	;
	;
	;P.I-24   undefined variable 
	;     (VVEUNDF)
	;
	;     III-5  P.I-24 I-3.3  Expressions  expr
	;            Any attempt to evaluate an expratom containing an lvn, gvn, or svn
	;            with an undefined value is erroneous.
	;       III-5.1  KILL A S B=B(A)
	;       III-5.2  KILL ^VVE S A=A(^VVE)
	;       III-5.3  S A=2,B(2)=0 K A S B(A)=3
	;       III-5.4  K ^VVE W 12_^VVE(2)_34
	;
	;
	;P.I-24   algebraic quotient /
	;     (VVEDIV)
	;
	;     III-6  P.I-24 I-3.3.1 / produces the algebraic quotient
	;            Division by zero is erroneous.
	;       III-6.1  1/0
	;       III-6.2  0/0
	;       III-6.3  4/$L("")
	;       III-6.4  S A=2345979/0000E2+3
	;
	;
	;P.I-27   pattern match  intlit1.intlit2
	;     (VVEPAT)
	;
	;     III-7  P.I-27 I-3.3.3  Pattern match
	;            If repcount has the form of a range,  intlit1.intlit2, the first
	;            intlit gives the lower bound, and the second intlit the upper bound.
	;            It is erroneous if the upper bound is less than the lower bound.
	;       III-7.1  123?2.1N
	;       III-7.2  " ABC "'?2.0UP
	;       III-7.3  "    "?999999999.255" "
	;       III-7.4  S A=29,B=A?3.2N
