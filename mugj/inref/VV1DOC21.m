VV1DOC21	;VV1DOC V.7.1 -21-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-34.1  -2--7
	;       I-34.2  -2.000--00050.3
	;       I-34.3  -4235.786--84.95100
	;     I-35. expratoms are numlit
	;       I-35.1  1E1-1.10
	;       I-35.2  92.36E-2-12.36E+1
	;       I-35.3  00023.E3-98.0000E-2
	;       I-35.4  0.123E2-12300E-2
	;     I-36. expratoms are strlit
	;       I-36.1  "AB2"-"2AB"
	;       I-36.2  "2A2B"-"2E2B"
	;       I-36.3  "234E-1+1AJDB"-"2.008E+1.B5456"
	;       I-36.4  "ONE2A2B"-"00002E-2B"
	;     I-37. expratoms are lvn
	;       I-37.1  unsubscripted lvn
	;       I-37.2  subscripted lvn
	;
	;
	;Binary operators -1.3- (+, -, *, /, #, \(integer division))
	;     (V1BOA3)
	;
	;     algebraic product
	;
	;     I-38. expratom=0
	;       I-38.1  0*0
	;       I-38.2  0*1
	;       I-38.3  2*00
	;       I-38.4  -3*0.0E2
	;       I-38.5  0.0*-4
	;     I-39. left expratom>0, right expratom>0
	;       I-39.1  1*1
	;       I-39.2  2*3
	;       I-39.3  0.5*.5
	;       I-39.4  .01*4.0
	;     I-40. left expratom>0, right expratom<0
	;       I-40.1  3*-2
	;       I-40.2  .3*-0.3
	;     I-41. left expratom<0, right expratom>0
	;       I-41.1  -2*4
	;       I-41.2  -597.2*25
	;       I-41.3  -.023*00.190
	;     I-42. left expratom<0, right expratom<0
	;       I-42.1  -3*-4
	;       I-42.2  -2.0*-50.3
	;       I-42.3  -.00239*-.092
