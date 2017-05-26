VV1DOC64	;VV1DOC V.7.1 -64-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-452. Value of indirection is numeric literal
	;
	;
	;Argument level indirection -5-
	;     (V1IDARG5)
	;
	;     XECUTE command
	;
	;     I-453. indirection of xecuteargument
	;     I-454. indirection of xecuteargument list
	;     I-455. 2 levels of xecuteargument indirection
	;     I-456. 3 levels of xecuteargument indirection
	;     I-457. Value of indirection contains name level indirection
	;     I-458. Value of indirection contains operators
	;     I-459. Value of indirection contains function
	;     I-460. Value of indirection contains argument level indirection
	;
	;
	;XECUTE command -1.1-
	;     (V1XECA1)
	;
	;     I-805. Single argument
	;     I-806. Argument list
	;     I-807. Interpretation of argument as expression
	;       I-807.1  SET command
	;       I-807.2  argument contains _ operator
	;     I-808. Postconditional of arguments
	;       I-808.1  tvexpr is true
	;       I-808.2  tvexpr is false
	;       I-808.3  tvexpr contains indirection
	;     I-809. Postconditional of command word
	;       I-809.1  tvexpr is true
	;       I-809.2  tvexpr is false
	;
	;
	;XECUTE command -1.2-
	;     (V1XECA2)
	;
	;     (V1XECA2 is overlaid with V1XECAE.)
	;
	;     I-810. Argument level indirection
	;       I-810.1  1 level
	;       I-810.2  2 level
	;       I-810.3  value of indirection contains postcondition
	;     I-811. GOTO command in XECUTE command
