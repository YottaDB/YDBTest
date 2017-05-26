VV2DOC10	;VV2DOC V.7.1 -10-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;        II-170.2  subscript is one character (all graphic characters)
	;
	;
	;String subscript -1-
	;     (VV2SS1)
	;
	;     II-171. Local variable primitive sequence
	;     II-172. Global variable primitive sequence
	;     II-173. Length of local variable subscript is 31 characters
	;     II-174. Length of local variable is 63 characters
	;     II-175. Length of global variable subscript is 31 characters
	;     II-176. Length of global variable is 63 characters
	;
	;
	;String subscript -2-
	;     (VV2SS2)
	;
	;     II-177. Naked reference when length of global variable is 63 characters
	;     II-178. Maximum and minimum number of local variable subscript
	;     II-179. Maximum and minimum number of global variable subscript
	;     II-180. Number of local variable subscripts is 31 (max)
	;     II-181. Number of global variable subscripts is 31 (max)
	;
	;
	;END.
