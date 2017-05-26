VVEDOC6	;VVEDOC V.7.1 -6-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;
	;P.I-36   FOR command, numexpr1:numexpr2:numexpr3 and numexpr2>=0 
	;     (VVEFORB)
	;
	;     III-14  P.I-36 I-3.6.5  FOR command (1)
	;             b. If the forparameter is of the form numexpr1:numexpr2:numexpr3
	;                and numexpr2 is nonnegative.
	;                6. Execute the scope once; an undefined value for lvn is
	;                   erroneous.
	;       III-14.1  FOR I=1:1:10 S A=I W I K:A=3 I
	;       III-14.2  S A=1 F I=1:0:10 S A=A+1 W A I A=7 K I
	;       III-14.3  F I=2:2:20 D KILL   ;(KILL W I IF I=10 K I)
	;       III-14.4  X "F A(2)=1:1:10 W A(2) IF A(2)=5 KILL A"
	;
	;
	;P.I-36   FOR command, numexpr1:numexpr2:numexpr3 and numexpr2<0
	;     (VVEFORC)
	;
	;     III-15  P.I-36 I-3.6.5  FOR command (2)
	;             c. If the forparameter is of the form numexpr1:numexpr2:numexpr3
	;                and numexpr2 is negative.
	;                6. Execute the scope once; an undefined value for lvn is
	;                   erroneous.
	;       III-15.1  FOR I=10:-1:1 S A=I K:A=3 I W A
	;       III-15.2  F I=10:-2:2 D KILL    ;(KILL W I IF I=6 K I)
	;       III-15.3  S A="I",C=0 F I=10:-1:1 S C=C+1 W C IF C=5 K @A
	;       III-15.4  S A=1,B=-1,C=10 F I=A:B:C K B,C S A=A+1,I=9 W A IF A=5 KILL I
	;
	;
	;P.I-36  FOR command, numexpr1:numexpr2
	;     (VVEFORD)
	;
	;
	;
	;     III-16  P.I-36 I-3.6.5  FOR command (3)
	;             d. If the forparameter is of the form numexpr1:numexpr2 .
	;                4. Execute the scope once; an undefined value for lvn is
	;                   erroneous.
	;       III-16.1  FOR I=1:1 S A=I W I K:I=3 I
	;       III-16.2  FOR I=10:-1 W I K:I=3 I
	;       III-16.3  F I=1:1 D KILL   ;(KILL W I IF I=6 K I)
	;       III-16.4  S A=0 F I=0:0 S A=A+1 W A I A=6 K I
	;
	;
	;
