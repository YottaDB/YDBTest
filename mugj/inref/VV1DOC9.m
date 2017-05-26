VV1DOC9	;VV1DOC V.7.1 -9-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;
	;     I-662. deletion of leading zero, while expr>1
	;       I-662.1  1
	;       I-662.2  02
	;       I-662.3  0003
	;       I-662.4  00004
	;       I-662.5  0000050
	;       I-662.6  0000006
	;       I-662.7  00000007000
	;       I-662.8  000000000000000000
	;       I-662.9  0000000000000000000000000000000000000000000000012300
	;       I-662.10  0000050.002
	;       I-662.11  000000645.23000
	;     I-663. deletion of leading zero, while expr<1
	;       I-663.1  -1
	;       I-663.2  -02
	;       I-663.3  -0003
	;       I-663.4  -00004
	;       I-663.5  -0000050
	;       I-663.6  -0000006
	;       I-663.7  -00000007000
	;       I-663.8  -000000000000000000
	;       I-663.9  -0000000000000000000000000000000000000000000000012300
	;       I-663.10  -0000006.034501
	;       I-663.11  -00000007000.00900000
	;     I-664. deletion of trailing zero, while expr is integer
	;       I-664.1  1.
	;       I-664.2  2.000000
	;       I-664.3  3200.0000000000
	;       I-664.4  -3.00000000
	;       I-664.5  -300.0000000000
	;       I-664.6  -.0000000000000000000
	;
	;
	;Interpretation of expr to numeric literal -2-
	;     (V1NUM2)
	;
	;     I-665. deletion of trailing zero, while expr is non-integer
	;       I-665.1  1.23
	;       I-665.2  456.7890
	;       I-665.3  0.0100
	;       I-665.4  .020
	;       I-665.5  -.0000500000
	;       I-665.6  000001.000100000
	;       I-665.7  -00000.200000
