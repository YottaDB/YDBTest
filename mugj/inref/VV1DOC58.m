VV1DOC58	;VV1DOC V.7.1 -58-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-338/339/342.2  numexpr1=numexpr3 and numexpr2>0
	;       I-338/339/342.3  numexpr1>numexpr3 and numexpr2>0
	;     I-340. numexpr1=numexpr3 and numexpr2=0
	;       I-340.1  numexpr1<numexpr3 and numexpr2=0
	;       I-340.2  numexpr1=numexpr3 and numexpr2=0
	;       I-340.3  numexpr1>numexpr3 and numexpr2=0
	;       I-340.4  numexpr1<numexpr3 and numexpr2=0 another
	;     I-341. numexpr1=numexpr3 and numexpr2<0
	;     I-343. numexpr1>numexpr3 and numexpr2<0
	;       I-341/343.1  numexpr1<numexpr3 and numexpr2<0
	;       I-341/343.2  numexpr1=numexpr3 and numexpr2<0
	;       I-341/343.3  numexpr1>numexpr3 and numexpr2<0
	;     I-344. numexpr1=numexpr2=numexpr3
	;       I-344.1  numexpr>0
	;       I-344.2  numexpr=0
	;       I-344.3  numexpr<0
	;
	;
	;FOR command -1.2-
	;     (V1FORA2)
	;
	;     I-345. 5 levels of FOR nesting
	;     I-346. GOTO command in FOR scope
	;     I-347. QUIT command in FOR scope
	;       I-347.1  QUIT without postcondition
	;       I-347.2  QUIT with postcondition
	;     I-348. XECUTE command in FOR scope
	;     I-349. numexpr is string literal
	;
	;     FOR lvn=numexpr1:numexpr2
	;
	;     I-350. numexpr1>0 and numexpr2>0
	;     I-351. numexpr1>0 and numexpr2<0
	;     I-352. numexpr1<0 and numexpr2>0
	;     I-353. numexpr1<0 and numexpr2<0
	;     I-354. numexpr2=0
	;
	;
	;FOR command -2-
	;     (V1FORB)
	;
	;     List of forparameter
	;
	;     I-355. forparameter is expr
	;     I-356. forparameter is numexpr1:numexpr2
