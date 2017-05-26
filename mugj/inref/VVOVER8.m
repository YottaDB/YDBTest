VVOVER8	;Overview V.7.1 -8-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;7.  Examples of Part-I, -II, and -III
	;
	;7.1  Part-I
	;
	;Example: V1JST3
	;
	;V1JST3: TEST OF $JUSTIFY, $SELECT AND $TEXT FUNCTIONS -3-
	;
	;$SELECT(L tvexpr:expr)
	;
	;I-586  single argument
	;   PASS  I-586  
	;I-587  effect on $TEST
	;   PASS  I-587.1  $TEST=1
	;   PASS  I-587.2  $TEST=0
	;I-588  interpretation sequence of $SELECT argument
	;   PASS  I-588  
	;I-589  interpretation of tvexpr
	;   PASS  I-589  
	;I-590  interpretation of expr, while tvexpr=0
	;   PASS  I-590  
	;I-591  interpretation of expr, while tvexpr=1
	;   PASS  I-591  
	;I-592  nesting of functions
	;   PASS  I-592  
	;
	;$TEXT(lineref),  $TEXT(+intexpr)
	;
	;I-593  the line specified by lineref does not exist
	;   PASS  I-593  
	;I-594  the line specified by +intexpr does not exist
	;   PASS  I-594  
	;I-595  the line specified by lineref exist
	;   PASS  I-595.1  lineref is a label
	;   PASS  I-595.2  lineref is a another label
	;   PASS  I-595.3  nesting of function
	;I-596  the line specified by +intexpr exist
	;   PASS  I-596  
	;I-597  lineref=label
	;   PASS  I-597  
	;I-598  lineref=label+intexpr
	;   PASS  I-598  
	;I-599/600  indirection of argument
	;   PASS  I-599/600  
	;
	;END OF V1JST3
	;
