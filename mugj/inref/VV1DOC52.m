VV1DOC52	;VV1DOC V.7.1 -52-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-381.3  01
	;       I-381.4  10
	;       I-381.5  12
	;       I-381.6  100
	;       I-381.7  012
	;       I-381.8  0012
	;       I-381.9  92345678
	;       I-381.10  00000000
	;     I-384. label is alpha and digit
	;       I-384.1  label is combination of a alpha and a digit
	;       I-384.2  label is combination of a alpha and digits
	;       I-384.3  label is combination of alphas and digits
	;
	;
	;GOTO command ( local branching ) -2-
	;     (V1GO2)
	;
	;     GOTO label+intexpr
	;
	;     I-385. intexpr is positive integer
	;     I-386. intexpr is zero
	;     I-387. intexpr is non-integer numeric literal
	;     I-388. intexpr is function
	;     I-389. intexpr is gvn
	;     I-390. intexpr contains binary operator
	;     I-391. intexpr contains unary operator
	;     I-392. intexpr contains gvn as expratom
	;     I-827. argument list label without postcondition
	;     I-828. argument list label+intexpr without postcondition
	;
	;
	;GOTO command ( overlay with external routine )
	;     (V1OV)
	;
	;     (V1OV is overlaid with V1OV1.)
	;
	;     I-677. postconditional of argument
	;     I-678. GOTO ^routineref
	;
	;     GOTO label^routineref
	;
	;     I-679. label is alpha
	;     I-685. label is alpha
	;       I-679/685  label is alpha
	;     I-680. label is intlit
