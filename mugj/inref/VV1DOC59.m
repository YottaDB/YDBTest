VV1DOC59	;VV1DOC V.7.1 -59-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-357. forparameter is numexpr1:numexpr2:numexpr3
	;     I-358. forparameter is mixture of the three above
	;
	;     FOR lvn=forparameter
	;
	;     I-359. Value of lvn in execution of FOR scope
	;     I-360. lvn has subscript
	;       I-360.1  3 subscripts
	;       I-360.2  1 subscript
	;       I-360.3  subscript contains binary operator
	;     I-361. Interpretation sequence of forparameter
	;       I-361.1  forparameter is expr
	;       I-361.2  forparameter is numexpr1:numexpr2
	;       I-361.3  forparameter is numexpr1:numexpr2:numexpr3
	;       I-361.4  numexpr2 is lvn
	;     I-362. forparameter contains lvn
	;     I-363. Change the Value of lvn in FOR scope
	;       I-363.1  SET lvn=lvn+1
	;       I-363.2  DO command in FOR scope
	;
	;
	;FOR command -3.1-
	;     (V1FORC1)
	;
	;     FOR lvn=numexpr1:numexpr2:numexpr3
	;
	;     I-364. numexpr is non-integer numeric literal
	;     I-365. numexpr is function
	;     I-366. numexpr contains unary operator
	;     I-367. numexpr contains binary operator
	;     I-368. numexpr is unsubscripted gvn
	;     I-369. numexpr is subscripted gvn
	;
	;     Combination of FOR scope
	;
	;     I-370. FOR ... QUIT ... FOR
	;     I-371. FOR ... QUIT ... FOR ... QUIT
	;     I-372. FOR ... FOR ... QUIT
	;
	;
	;FOR command -3.2-
	;     (V1FORC2)
	;
	;     I-373. FOR ... FOR ... QUIT ... FOR ... QUIT
	;     I-374. FOR ... FOR ... GOTO
