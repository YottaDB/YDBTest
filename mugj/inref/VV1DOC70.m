VV1DOC70	;VV1DOC V.7.1 -70-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Special variable $STORAGE
	;     (V1SVS)
	;
	;     I-795. Format of $S
	;     I-796. Effect on $STORAGE by setting local variables
	;       I-796.1  "KILL ALL"
	;       I-796.2  "SET A=1234567"
	;       I-796.3  "SET B=$S"
	;     I-797. Partition size for assurance of routine transferability (4000 Byte)
	;
	;
	;Various maximum range -1-
	;     (V1MAX1)
	;
	;     I-619. 255 characters in one routine line
	;       I-619.1  write command
	;       I-619.2  set command
	;     I-620. 255 characters in one data of lvn
	;     I-621. 255 characters in one data of gvn
	;     I-622. numeric range ( 10 power -25 to 10 power 25 )
	;     I-623. significant digit up to 9 digits
	;       I-623.1  local data
	;       I-623.2  global data
	;
	;
	;Various maximum range -2-
	;     (V1MAX2)
	;
	;     I-624. 9 digits subscript of local variable
	;     I-625. 9 digits subscript of global variable
	;     I-626. 15 levels subscript of local variable
	;     I-627. 15 levels subscript of global variable
	;
	;
	;BREAK command
	;     (V1BR)
	;
	;     (V1BR is overlaid with V1BR1.)
	;
	;     I-165. restarting point
	;     I-166. breaking point
	;       I-165/166  breaking point and restarting point
	;     I-167. post conditional
	;       I-167.1  postcondition is true
	;       I-167.2  postcondition is false
