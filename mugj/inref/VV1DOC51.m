VV1DOC51	;VV1DOC V.7.1 -51-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;SET command
	;     (V1SET)
	;
	;     SET L setargument
	;        setargument ::= [ [ glvn or (L glvn) ] = expr ]
	;
	;     I-781. expr is string literal
	;       I-781.1  subscripted variables assigned with constant values
	;       I-781.2  variables' values reassigned to other variables
	;     I-782. expr is lvn
	;     I-783. expr is gvn
	;     I-784. glvn is subscripted variable
	;     I-785. Multi-Assignment of unsubscripted variables
	;     I-786. Multi-Assignment of subscripted variables
	;     I-787. Execution sequence of SET command
	;
	;
	;GOTO command ( local branching ) -1-
	;     (V1GO1)
	;
	;     GOTO label
	;
	;     I-382. label is % and alpha
	;     I-383. label is % digit
	;       I-382/383.1  label is %
	;       I-382/383.2  label is % followed by a alpha
	;       I-382/383.3  label is % followed by alphas
	;       I-382/383.4  label is % followed by a digit
	;       I-382/383.5  label is % followed by 2 digits
	;       I-382/383.6  label is % followed by 7 digits
	;       I-382/383.7  label is % followed by another 7 digits
	;       I-382/383.8  label is % followed by combination of a alpha and a digit
	;       I-382/383.9  label is % followed by combination of alphas and digits
	;     I-380. label is alpha
	;       I-380.1  label is a alpha
	;       I-380.2  label is different alpha
	;       I-380.3  label is different alpha
	;       I-380.4  label is 2 alphas
	;       I-380.5  label is another 2 alphas
	;       I-380.6  label is 4 alphas
	;       I-380.7  label is 3 alphas
	;       I-380.8  label is 8 alphas
	;     I-381. label is digit
	;       I-381.1  0
	;       I-381.2  1
