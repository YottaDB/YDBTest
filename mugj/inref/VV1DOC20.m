VV1DOC20	;VV1DOC V.7.1 -20-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-25.3  -0987.34+987.340
	;       I-25.4  -.345+.344
	;     I-26. left expratom<0, right expratom<0
	;       I-26.1  -2+-7
	;       I-26.2  -2.0+-50.3
	;       I-26.3  -0.567+-.433
	;       I-26.4  -0.000345+-00.0000345
	;     I-27. expratoms are numlit
	;       I-27.1  1E1+1.10
	;       I-27.2  92.36E-2+12.36E+1
	;       I-27.3  00023.E3+98.0000E-2
	;       I-27.4  .123E2+12300E-2
	;     I-28. expratoms are strlit
	;       I-28.1  "2A2B"+"2E2B"
	;       I-28.2  "234E-1+1AJDB"+"2E+2B"
	;       I-28.3  "ONE2A2B"+"00002E-2B"
	;     I-29. expratoms are lvn
	;       I-29.1  unsubscripted lvn
	;       I-29.2  subscripted lvn
	;
	;
	;Binary operators -1.2- (+, -, *, /, #, \(integer division))
	;     (V1BOA2)
	;
	;     algebraic difference
	;
	;     I-30. expratom=0
	;       I-30.1  0-0
	;       I-30.2  1-0
	;       I-30.3  000-2
	;       I-30.4  0-+.999
	;       I-30.5  00000-00000.00000E2
	;     I-31. left expratom>0, right expratom>0
	;       I-31.1  2-3
	;       I-31.2  0.5-0.5
	;       I-31.3  0.01-4
	;     I-32. left expratom>0, right expratom<0
	;       I-32.1  5--2
	;       I-32.2  .3--0.3
	;       I-32.3  876.653--5.62
	;     I-33. left expratom<0, right expratom>0
	;       I-33.1  -1-5
	;       I-33.2  -597.2-25
	;       I-33.3  -1176.59-20000
	;     I-34. left expratom<0, right expratom<0
