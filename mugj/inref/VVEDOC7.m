VVEDOC7	;VVEDOC V.7.1 -7-;TS,VVEDOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-III
	;
	;P.I-39  KILL command, undefined variable
	;     (VVEKILL)
	;
	;     III-17  P.I-39 I-3.6.10  KILL command
	;             Killing the variable M sets $D(M) = 0 and causes the value of M
	;             to be undefined.  Any attempt to obtain the value of M while it
	;             is undefined is erroneous.
	;       III-17.1  S A=10 KILL A S B=A
	;       III-17.2  S ^VVE=0 KILL ^VVE S A=^VVE
	;       III-17.3  S A(2)=8 K A W A(2)
	;       III-17.4  S ^VVE(1,2,20)=123 K ^VVE W ^VVE(1,2,20)
	;
	;
	;P.I-43  READ command, readcount
	;     (VVEREAD)
	;
	;     III-18  P.I-43 I-3.6.14  READ command
	;             When the form of the argument is lvn # intexpr [timeout], let n
	;             be the value of intexpr. It is erroneous if n <=0.
	;       III-18.1  K A READ A#-1
	;       III-18.2  S A=99 R A#-999999999
	;       III-18.3  S A=123,B=0 R A#B
	;       III-18.4  K B S A=-3 R B#A:10
	;
	;
	;P.III-4  string length
	;     (VVELIMS)
	;
	;     III-19  P.III-4 III-3.2  Results (1)
	;             Any results, whether intermediate or final, which does not satisfy
	;             the constraints on character strings (Section 2.7) is erroneous.
	;       III-19.1  S A="" F I=1:1:256 S A=A_"a"
	;       III-19.2  S C=A_B  ;$L(A_B)=300
	;       III-19.3  W (A_B)=(AA_BB)   ;$L(A_B)=510
	;       III-19.4  W $L(^VVE(1)_^VVE(2))   ;$L(^VVE(1)_^VVE(2))=510
	;
	;
	;
	;
	;
	;
	;
	;
	;
	;
