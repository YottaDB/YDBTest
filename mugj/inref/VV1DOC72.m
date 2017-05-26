VV1DOC72	;VV1DOC V.7.1 -72-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-764. Value of lvn, when input is terminated
	;       I-763/764.1  READ lvn timeout
	;       I-763/764.2  READ *lvn timeout
	;     I-765. Value of $TEST, when input is not terminated
	;     I-766. Value of lvn, when input is not terminated
	;       I-765/766.1  READ lvn timeout
	;       I-765/766.2  empty string
	;
	;
	;READ command -2.2-
	;     (V1READB2)
	;
	;     I-767. indirection of readargument except format
	;     I-768. indirection of readargument list
	;     I-769. indirection of format control parameters
	;     I-770. 2 levels of readargument indirection
	;     I-771. 3 levels of readargument indirection
	;     I-772. Value of indirection contains indirection
	;     I-773. Value of indirection contains operators
	;     I-774. Value of indirection is function
	;     I-775. Value of indirection is lvn
	;
	;
	;HANG command
	;     (V1HANG)
	;
	;     I-401. HANG duration by $H
	;     I-402. List of hangargument
	;     I-403. HANG in FOR scope
	;     I-404. HANG with postconditional
	;     I-405. argument level indirection
	;     I-406. name level indirection
	;
	;     HANG intexpr
	;
	;     I-407. intexpr is integer
	;     I-408. intexpr=0
	;     I-409. intexpr<0
	;     I-410. intexpr is non-integer positive numeric literal
	;     I-411. intexpr is greater than zero and less than one
	;     I-412. intexpr is string literal
	;     I-413. intexpr is empty string
	;     I-414. intexpr is lvn
	;     I-415. intexpr contains unary operator
	;     I-416. intexpr contains binary operator
