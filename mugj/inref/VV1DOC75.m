VV1DOC75	;VV1DOC V.7.1 -75-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-637. effect of LOCK on local variable reference
	;     I-638. ( This test I-638 was nullified 1978 ANSI, MSL )
	;
	;
	;Multi job ( LOCK, OPEN, CLOSE, $JOB, $IO, $TEST ) -2-
	;     (V1MJB)
	;
	;     I-639. OPEN the same device from two partitions
	;     I-640. OPEN with timeout and its effect on $TEST
	;     I-641. argument list of OPEN command
	;     I-642. effect of CLOSE on another partition
	;     I-643. postconditional of CLOSE command
	;     I-644. CLOSE the device which is not OPENed
	;     I-645. format of $JOB
	;     I-646. value of $JOB on two partitions
	;     I-647. $IO when Principal Device Convention is adopted
	;
	;
	;END
	;
