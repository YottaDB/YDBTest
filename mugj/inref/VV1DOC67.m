VV1DOC67	;VV1DOC V.7.1 -67-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-653. 1 level of DO, and 14 levels of FOR
	;       I-653.1  termination by GOTO
	;       I-653.2  termination by QUIT
	;     I-654. 1 level of DO, and 14 levels of XECUTE
	;     I-655. 15 levels of DO
	;       I-655.1  local DO
	;       I-655.2  external DO
	;     I-656. 15 levels of combinated DO, FOR, XECUTE
	;
	;
	;Nesting level -2-
	;     (V1NST2)
	;
	;     I-657. 1 level of DO, and 14 levels of argument level indirection
	;     I-658. 1 level of DO, and 14 levels of name level indirection
	;     I-659. up to 6 levels nesting of functions
	;
	;
	;Nesting level -3-
	;     (V1NST3)
	;
	;     I-660. effect of GOTO command on nesting
	;       I-660.1  local GOTO
	;       I-660.2  external GOTO
	;     I-661. effect of QUIT command on nesting
	;
	;
	;$JUSTIFY, $SELECT, $TEXT -1-
	;     (V1JST1)
	;
	;     $JUSTIFY(expr1, intexpr2)
	;
	;     I-555. expr1 is string literal
	;     I-556. expr1 is empty string
	;     I-557. expr1 is positive integer
	;       I-557.1  0001234.0000
	;       I-557.2  000123400.00E1
	;     I-558. expr1 is negative integer
	;       I-558.1  -00098
	;       I-558.2  -0009800.00
	;     I-559. expr1 is positive non-integer numeric
	;     I-560. expr1 is negative non-integer numeric
	;     I-561. expr1 is greater than zero and less than one
	;     I-562. expr1 contains binary operator
	;       I-562.1  "12AHD"*"12"                            
