VV1DOC8	;VV1DOC V.7.1 -8-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-780. Maximum length of routinename
	;
	;
	;Preliminary test of SET command
	;     (V1PRSET)
	;
	;     I-734. SET local variables without subscript
	;     I-735. setargument list
	;     I-736. reassignment
	;     I-737. KILL local variables all
	;
	;
	;Preliminary test of IF, and ELSE command
	;     (V1PRIE)
	;
	;     I-731. interpretation of ifargument
	;     I-733. combination of IF and ELSE command
	;       I-731/733.1  ifargument is 0 
	;       I-731/733.2  ifargument is 1 
	;       I-731/733.3  ifargument is 2 
	;       I-731/733.4  ifargument is -1 
	;       I-731/733.5  ifargument is -0.00000001 
	;       I-731/733.6  list of IF command and all ifargument is true
	;       I-731/733.7  list of IF command and a ifargument is false
	;     I-732. argument list of IF command
	;     I-733. combination of IF and ELSE command
	;       I-732/733.1  all ifargument is true
	;       I-732/733.2  a ifargument is false
	;
	;
	;Preliminary test of FOR command
	;     (V1PRFOR)
	;
	;     FOR lvn=numexpr1:numexpr2:numexpr3
	;
	;     I-724. numexpr1<numexpr3 and numexpr2>0
	;       I-724.1  numexpr2=1
	;       I-724.2  numexpr2=3
	;     I-725. numexpr1>numexpr3 and numexpr2<0
	;       I-725.1  numexpr2=-1
	;       I-725.2  numexpr2=-3
	;
	;
	;Interpretation of expr to numeric literal -1-
	;     (V1NUM1)
