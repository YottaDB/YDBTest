VVOVER11	;Overview V.7.1 -11-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;II-114  expr1 is empty string
	;** FAIL  II-114  
	;           COMPUTED ="ABCD ABCD ABCDE ABCD"
	;           CORRECT  ="D ABCD ABCDE D"
	;II-115  Value of glvn is numeric data
	;   PASS  II-115  
	;II-116  Control characters are used as delimiters (expr1)
	;   PASS  II-116  
	;II-117  Value of expr1 contains operators
	;   PASS  II-117  
	;II-118  intexpr2 and intexpr3 are numlits
	;   PASS  II-118  
	;II-119  Value of expr1,intexpr2,intexpr3 are functions
	;   PASS  II-119.1  $C
	;   PASS  II-119.2  $L
	;   PASS  II-119.3  $P
	;
	;END OF VV2LHP2
	;
	;-----------------------------------------------------------------------
	;     END OF TEST -- VV2LHP2      Std. MUMPS Conformance Test V.7.1.
	;     13 tests were executed.
	;        0 visual    Test(s).
	;       13 automatic Test(s) (    12 passed,     1 failed,   0 aborted! ).
	;
	;
	;Example: VV2PAT2
	;
	;VV2PAT2: TEST OF PATTERN MATCH OPERATOR -2-
	;
	;II-155  Indirection pattern
	;   PASS  II-155  
	;II-156  Nesting of pattern
	;
	;ION"?@("TEST"?4A_"""VALIDATION""")_"A"_($P("ABC/DDD","/")?.N+3_"U"_"1"
	;                                                              *
	;NOT USED (FOR EXPANSION)   // (Error message from the system)
	;
	;156+2^VV2PAT2           // (Error stops are counted as "aborted" tests, 
	;                        //  and resumption of validation is usually made by
	;                        //  DOing the next item number.)
	;                                           |
	;>D 157^VV2PAT2  <--------------------------+
	;
	;II-157  expr is 255 characters
	;   PASS  II-157  
	;II-158  expr ? repcount strlit when strlit is empty string
