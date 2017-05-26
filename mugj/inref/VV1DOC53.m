VV1DOC53	;VV1DOC V.7.1 -53-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-686. label is intlit
	;       I-680/686  label is intlit
	;     I-681. label is "%"
	;     I-682. label is "%" and alpha
	;     I-683. label is "%" and digit
	;     I-684. label is "%" and combination of alpha and digit
	;     I-687. label is combination of alpha and digit
	;
	;     GOTO label+intexpr^routineref
	;
	;     I-688. intexpr is positive integer
	;     I-689. intexpr is zero
	;     I-690. intexpr is non-integer numeric
	;     I-691. intexpr contains binary operators
	;     I-692. intexpr contains unary operators
	;     I-693. intexpr is function
	;     I-694. intexpr is gvn
	;     I-695. intexpr contains gvn as expratom
	;     I-676. argument list
	;     I-829. argument list ^routineref without postcondition
	;       I-676/829  argument list ^routineref without postcondition
	;     I-676. argument list
	;     I-830. argument list label^routineref without postcondition
	;       I-676/830  argument list label^routineref without postcondition
	;     I-676. argument list
	;     I-831. argument list label+intexpr^routineref without postcondition
	;       I-676/831  argument list label+intexpr^routineref without postcondition
	;
	;       The checked items in V1OV are in most part same as the items of V1CALL.
	;
	;
	;DO command ( local branching ) -1-
	;     (V1DO1)
	;
	;     DO label
	;
	;     I-238. label   label is % and alpha
	;     I-239. label   label is % and digit
	;       I-238/239.1  label is a %
	;       I-238/239.2  label is a % followed by an alpha
	;       I-238/239.3  label is a % followed by 7 alphas
	;       I-238/239.4  label is a % followed by a digit
	;       I-238/239.5  label is a % followed by 2 digits
	;       I-238/239.6  label is a % followed by 7 digits
	;       I-238/239.7  label is a % followed by another 7 digits
