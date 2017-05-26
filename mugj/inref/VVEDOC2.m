VVEDOC2	;VVEDOC V.7.1 -2-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;
	;2)  Session titles (Routine names)
	;    Section titles with ID numbers and propositions
	;    Tests with ID numbers and propositions
	;
	;
	;P.I-12   naked indicator undefined 
	;     (VVENAK)
	;
	;     III-1  P.I-12 I-3.2.2.2  Global Variale Name
	;            Prior to the first executed occurrence of a nonnaked form of
	;            gvn, the value of the naked indicator is undefined. It is erroneous
	;            for the first executed occurrence of gvn to be a naked reference.
	;            A nonnaked reference without subscripts leaves the naked indicator
	;            undefined.
	;       III-1.1  S ^VVE(2)=2,^VVE=0 S B=^(2)
	;       III-1.2  S ^VVE(2)=2 S A=$D(^VVE),B=$D(^(2))
	;       III-1.3  S ^VVE(2,2)=22,^VVE=0 S A=^(2,2)
	;       III-1.4  S ^VVE(2,2)=22,^VVE=0 W $O(^(2,2))
	;
	;
	;P.I-22   $RANDOM 
	;     (VVERAND)
	;
	;     III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)
	;            If the value of intexpr is less than 1, an error will occur.
	;       III-2.1  $RANDOM(0)
	;       III-2.2  $R(00.999999999)
	;       III-2.3  S A=$R(-1)
	;       III-2.4  S A=-99999999.9,B=$R(A)
	;
	;
	;P.I-22   $SELECT 
	;     (VVESEL)
	;
	;     III-3  P.I-22 I-3.2.8  $SELECT(L |tvexpr:expr|)
	;            An error will occur if all tvexprs are false.
	;       III-3.1  $SELECT(0:"** FAIL $SELECT 1")
	;       III-3.2  $S(0:"** FAIL $SELECT 2",'1:"** FAIL $SELECT 3")
	;       III-3.3  $L($S(0:"** FAIL $SELECT 4","00""11DEFG":"** FAIL $SELECT 5"))
	;       III-3.4  S A=0 W $S(A+A:"** FAIL $SELECT 6",A:"** FAIL $SELECT 7")
	;
	;
	;
	;
