VV1DOC54	;VV1DOC V.7.1 -54-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-238/239.8  label is a % followed by combination of an alpha and a digit
	;       I-238/239.9  label is a % followed by combination of alphas and digits
	;       I-238/239.10  label is a % followed by combination of digits and alphas
	;
	;
	;DO command ( local branching ) -2-
	;     (V1DO2)
	;
	;     I-236. label   label is an alpha followed by alpha and/or digit
	;       I-236.1  label is an alpha
	;       I-236.2  label is a different alpha
	;       I-236.3  label is a different alpha
	;       I-236.4  label is 2 alphas
	;       I-236.5  label is another 2 alphas
	;       I-236.6  label is 4 alphas
	;       I-236.7  label is 3 alphas
	;       I-236.8  label is 8 alphas
	;       I-236.9  label is an alpha followed by combination of an alpha and a digit
	;       I-236.10  label is an alpha followed by combination of digits and an alpha
	;       I-236.11  label is an alpha followed by combination of alphas and digits
	;     I-237. label   label is intlit
	;       I-237.1  label is 0
	;       I-237.2  label is 1
	;       I-237.3  label is 01
	;       I-237.4  label is 10
	;       I-237.5  label is 12
	;       I-237.6  label is 100
	;       I-237.7  label is 012
	;       I-237.8  label is 0012
	;       I-237.9  label is 92345678; 8 digits
	;       I-237.10  label is 00000000; 8 digits
	;
	;
	;DO command ( local branching ) -3-
	;     (V1DO3)
	;
	;     DO label+intexpr
	;
	;     I-240. label+intexpr   intexpr is positive integer
	;     I-241. label+intexpr   intexpr is zero
	;     I-242. label+intexpr   intexpr is non-integer numlit
	;     I-243. label+intexpr   intexpr is function
	;     I-244. label+intexpr   intexpr is gvn
	;     I-245. label+intexpr   intexpr contains binary operator
	;       I-245.1  + operator
