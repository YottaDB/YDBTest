VV1DOC60	;VV1DOC V.7.1 -60-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-374.1  a forparameter
	;       I-374.2  list of forparameter
	;     I-375. FOR ... GOTO ... FOR
	;     I-376. FOR ... FOR ... FOR ... GOTO
	;     I-377. FOR ... GOTO ... QUIT
	;     I-378. FOR ... QUIT ... FOR ... GOTO
	;     I-379. FOR ... FOR ... QUIT ... GOTO
	;
	;
	;Name level indirection -1-
	;     (V1IDNM1)
	;
	;     FOR command
	;
	;     I-489. indirection of lvn
	;     I-490. indirection of forparameters
	;     I-491. indirection of subscript of lvn
	;     I-492. value of indirection is function
	;     I-493. value of indirection is gvn
	;     I-494. value of indirection is lvn
	;     I-495. 2 levels of indirection
	;     I-496. 3 levels of indirection
	;
	;
	;Name level indirection -2-
	;     (V1IDNM2)
	;
	;     SET command
	;
	;     I-497. indirection of the left side lvn
	;     I-498. indirection of the right side lvn
	;     I-499. indirection of the left side gvn
	;     I-500. indirection of the right side gvn
	;     I-501. indirection of lvn subscript
	;     I-502. indirection of gvn subscript
	;     I-503. value of indirection is function
	;     I-504. value of indirection is gvn
	;     I-505. value of indirection is lvn
	;     I-506. value of indirection is numeric literal
	;     I-507. 2 levels of indirection
	;     I-508. 3 levels of indirection
	;
	;
	;Name level indirection -3-
	;     (V1IDNM3)
