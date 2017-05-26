VVEDOC4	;VVEDOC V.7.1 -4-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;
	;P.I-32   line references, intexpr<0
	;     (VVELINN)
	;
	;     III-8  P.I-32 I-3.5.7  Line References (1)
	;            lineref ::= dlabel [ + intexpr]
	;            A negative value of intexpr is erroneous.
	;       III-8.1  DO LR+-1
	;       III-8.2  S A=-2 D LR+A
	;       III-8.3  GOTO LR+-1
	;       III-8.4  S A=-2,B="LR" G @B+A
	;
	;
	;P.I-32   line references, a value of intexpr so large
	;         as not to denote a line within the bounds of
	;         the given routine
	;     (VVELINA)
	;
	;     III-9  P.I-32 I-3.5.7  Line References (2)
	;            In the context of DO or GOTO, either of the following conditions
	;            is erroneous
	;            a.  A value of intexpr so large as not to denote a line within the
	;                bounds of the given routine.
	;       III-9.1  D LINE+999
	;       III-9.2  G 2+999999999
	;       III-9.3  S A="%00000" D @A+99999.9999
	;       III-9.4  S B(2,1)="4",A=8760 G @B(2,1)+A
	;
	;
	;P.I-32   line references, a spelling of label which
	;         does not occur in a defining occurrence
	;         in the given routine
	;     (VVELINB)
	;
	;     III-10  P.I-32 I-3.5.7  Line References (3)
	;             In the context of DO or GOTO, either of the following conditions
	;             is erroneous
	;             b. A spelling of label which does not occur in a defining occurrence
	;                in the given routine.
	;       III-10.1  D %00000
	;       III-10.2  G QWERTY
	;       III-10.3  S A="LABEL" D @A
	;       III-10.4  S B(2)=12346 G @B(2)
	;
	;
