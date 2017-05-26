VV1DOC23	;VV1DOC V.7.1 -23-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-51.3  00023.E3/11.50000E-2
	;       I-51.4  .123E2/12300E-2
	;     I-52. expratoms are strlit
	;       I-52.1  "AB2"/"2AB"
	;       I-52.2  "2A2B"/"2E2B"
	;     I-53. expratoms are lvn
	;       I-53.1  unsubscripted lvn
	;       I-53.2  subscripted lvn
	;
	;
	;Binary operators -1.5- (+, -, *, /, #, \(integer division))
	;     (V1BOA5)
	;
	;     integer interpretation of algebraic quotient
	;
	;     I-54. expratom=0
	;       I-54.1  0\1
	;       I-54.2  0\-8
	;     I-55. left expratom>0, right expratom>0
	;       I-55.1  3\3
	;       I-55.2  8\2
	;       I-55.3  3\2
	;       I-55.4  3\4
	;       I-55.5  10\4
	;       I-55.6  0.5\.5
	;       I-55.7  4.1\0.01
	;     I-56. left expratom>0, right expratom<0
	;       I-56.1  11\-4
	;       I-56.2  0.3\-.3
	;       I-56.3  8083.5742\-808.6
	;     I-57. left expratom<0, right expratom>0
	;       I-57.1  -9\4
	;       I-57.2  -597.5\25
	;       I-57.3  -.005468\0.000113
	;     I-58. left expratom<0, right expratom<0
	;       I-58.1  -12\-4
	;       I-58.2  -50.3\-0.25
	;       I-58.3  -0.90136\-0.0001980
	;     I-59. expratoms are numlit
	;       I-59.1  1E1\1.10
	;       I-59.2  92.36E-2\12.36E+1
	;       I-59.3  26.29369\2.632
	;       I-59.4  0.123E2\12300E-2
	;     I-60. expratoms are strlit
	;       I-60.1  "AB2"\"2AB"
