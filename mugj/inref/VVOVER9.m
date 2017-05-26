VVOVER9	;Overview V.7.1 -9-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;-----------------------------------------------------------------------
	;     END OF TEST -- V1JST3      Std. MUMPS Conformance Test V.7.1.
	;     17 tests were executed.
	;        0 visual    Test(s).
	;       17 automatic Test(s) (    17 passed,     0 failed,   0 aborted! ).
	;
	; //  (Each routine produces individual result of "passing" or "failing" 
	; //   followed by a summary report per routine as above. )
	;
	;
	;Example: V1SVH
	;V1SVH: TEST OF SPECIAL VARIABLE ( $HOROLOG )
	;I-793  Format of $H
	;   PASS  I-793  
	;
	;I-794  Value of $H  (visual)
	;       CONFIRM THE FOLLOWING DATE AND TIME BY ACCURATE WATCH
	;       27-MAY-87  14:29:56
	;
	;END OF V1SVH
	;------------------------------------------------------------------------
	;     END OF TEST -- V1SVH      Std. MUMPS Conformance Test V.7.1.
	;     2 tests were executed.
	;        1 visual    Test(s) ( _____ passed, _____ failed ).
	;        1 automatic Test(s) (     1 passed,     0 failed,   0 aborted! ).
	;
	; // (This visual test is one example of the total 72 visual tests throughout
	; //  Part-I and -II that should be evaluated "visually".)
	;
	;
	;7.2  Part-II
	;
	;Example: VV2NO
	;
	;VV2NO: TEST OF $NEXT AND $ORDER
	;
	;  Though the use of "negative numeric subscripts" is restricted in Portability
	;Requirements 2.2.3, they are "arbitrarily" tested in $NEXT (function under way
	;of being switched to $ORDER). Such failures SHOULD NOT be counted as FAILURES.
	;
	;$NEXT(glvn)      // (Two "failures" in $NEXT are reported with "correct" 
	;                 // results, only serving to show the implementer's semantics.)
	;II-167  Sequence from -1 when glvn is lvn
	;** FAIL  II-167.1  subscript is a string
	;           COMPUTED ="-.5 0 .5 1.1 20 999999999 # % +4 - --1 -. -.5 0 .5 1.1 2
	;0 999999999 # % +4 - --1 -. -.0 -0 -4. -4.0 . .0 .00 0.0 0.1 00 01 1. 1.0 1.1.
	;2 123E1 A AA AB "
