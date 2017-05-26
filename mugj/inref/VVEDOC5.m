VVEDOC5	;VVEDOC V.7.1 -5-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;
	;P.I-32   line reference erroneous for external routine, intexpr<0
	;     (VVELINXN)
	;
	;     III-11  P.I-32 I-3.5.7  Line References (4), External routine reference
	;            lineref ::= dlabel [ + intexpr]
	;            A negative value of intexpr is erroneous.
	;       III-11.1  DO LR+-1^VVELINN
	;       III-11.2  S A=-2 D LR+A^VVELINN
	;       III-11.3  GOTO LR+-1^VVELINN
	;       III-11.4  S A=-2,B="LR" G @B+A^VVELINN
	;
	;
	;P.I-32   line reference erroneous for external routine,
	;         a value of intexpr so large as not to denote a line within the bounds
	;         of the given routine
	;     (VVELINXA)
	;
	;     III-12  P.I-32 I-3.5.7  Line References (5), External routine reference
	;            In the context of DO or GOTO, either of the following conditions
	;            is erroneous
	;            a.  A value of intexpr so large as not to denote a line within the
	;                bounds of the given routine.
	;       III-12.1  D LINE+999^VVELINA
	;       III-12.2  G 2+999999999^VVELINA
	;       III-12.3  S A="%00000" D @A+99999.9999^VVELINA
	;       III-12.4  S B(2,1)="4",A=8760 G @B(2,1)+A^VVELINA
	;
	;
	;P.I-32   line reference erroneous for external routine,
	;         a spelling of label which does not occur in a defining occurrence
	;         in the given routine
	;     (VVELINXB)
	;
	;     III-13  P.I-32 I-3.5.7  Line References (6), External routine reference
	;             In the context of DO or GOTO, either of the following conditions
	;             is erroneous
	;             b. A spelling of label which does not occur in a defining occurrence
	;                in the given routine.
	;       III-13.1  D %00000^VVELINB
	;       III-13.2  G QWERTY^VVELINB
	;       III-13.3  S A="LABEL" D @A^VVELINB
	;       III-13.4  S B(2)=12346 G @B(2)^VVELINB
	;
	;
