VVOVER10	;Overview V.7.1 -10-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;           CORRECT  ="-999999999 -10 -1.2 -1.11 -1.1 -1 -999999999 -10 -1.2 -1
	;.11 -1.1 -1 -.5 0 .5 1.1 20 999999999 # % +4 - --1 -. -.0 -0 -4. -4.0 . .0 .00
	; 0.0 0.1 00 01 1. 1.0 1.1.2 123E1 A AA AB "
	;   PASS  II-167.2  subscript is one character (all graphic characters)
	;II-168  Sequence from -1 when glvn is gvn
	;** FAIL  II-168.1  subscript is a string
	;           COMPUTED ="-.5 0 .5 1.1 20 999999999 # % +4 - --1 -. -.5 0 .5 1.1 2
	;0 999999999 # % +4 - --1 -. -.0 -0 -4. -4.0 . .0 .00 0.0 0.1 00 01 1. 1.0 1.1.
	;2 123E1 A AA AB "
	;           CORRECT  ="-999999999 -10 -1.2 -1.11 -1.1 -1 -999999999 -10 -1.2 -1
	;.11 -1.1 -1 -.5 0 .5 1.1 20 999999999 # % +4 - --1 -. -.0 -0 -4. -4.0 . .0 .00
	; 0.0 0.1 00 01 1. 1.0 1.1.2 123E1 A AA AB "
	;   PASS  II-168.2  subscript is one character (all graphic characters)
	;
	;
	;$ORDER(glvn)
	;
	;II-169  Sequence from empty string when glvn is lvn
	;   PASS  II-169.1  subscript is a string
	;   PASS  II-169.2  subscript is one character (all graphic characters)
	;II-170  Sequence from empty string when glvn is gvn
	;   PASS  II-170.1  subscript is a string
	;   PASS  II-170.2  subscript is one character (all graphic characters)
	;
	;END OF VV2NO
	;
	;-----------------------------------------------------------------------
	;     END OF TEST -- VV2NO      Std. MUMPS Conformance Test V.7.1.
	;     8 tests were executed.
	;        0 visual    Test(s).
	;        8 automatic Test(s) (     6 passed,     2 failed,   0 aborted! ).
	;
	;
	;Example: VV2LHP2
	;
	;VV2LHP2: TEST OF LEFT-HAND $PIECE -2-
	;
	;II-109  Naked indicator when intexpr2>intexpr3
	;   PASS  II-109  
	;II-110  Naked indicator when intexpr3<1
	;   PASS  II-110  
	;II-111  Lower case letter left hand "$piece"
	;   PASS  II-111  
	;II-112  Left hand $PIECE with postcondition
	;   PASS  II-112  
	;II-113  Indirection of left hand $PIECE
	;   PASS  II-113  
