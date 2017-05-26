VV1DOC71	;VV1DOC V.7.1 -71-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-168. BREAK in internal routine in DO command
	;     I-169. BREAK in external routine in DO command
	;     I-170. BREAK in FOR loop
	;     I-171. BREAK in XECUTE command
	;
	;       Stack is required to be maintained, when BREAK command is
	;       executed within DO command, FOR loop, and XECUTE command.
	;
	;
	;READ command -1.1-
	;     (V1READA1)
	;
	;     I-749. readargument is string literal
	;     I-750. readargument is format control characters
	;     I-751. Read empty string
	;     I-752. Read 255 characters length data
	;     I-753. Read upper-case alphabetics
	;     I-754. Read lower-case alphabetics
	;     I-755. Read punctuations
	;     I-756. Read numerics
	;
	;
	;READ command -1.2-
	;     (V1READA2)
	;
	;     I-757. READ *lvn
	;       I-757.1  'A'
	;       I-757.2  <ENTER>
	;     I-758. READ *lvn,*lvn,*lvn
	;     I-759. Read into subscripted variable
	;       I-759.1  READ lvn
	;       I-759.2  READ *lvn
	;
	;
	;READ command -2.1-
	;     (V1READB1)
	;
	;     I-760. timeout is equal to 0 or less than 0
	;     I-761. Value of $TEST of above
	;     I-762. Value of lvn of above
	;       I-760/761/762.1  READ lvn timeout and timeout is equal to 0
	;       I-760/761/762.2  READ *lvn timeout and timeout is equal to 0
	;       I-760/761/762.3  READ lvn timeout and timeout is less than 0
	;       I-760/761/762.4  READ *lvn timeout and timeout is less than 0
	;     I-763. Value of $TEST, when input is terminated
