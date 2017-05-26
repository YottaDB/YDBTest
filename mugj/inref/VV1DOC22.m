VV1DOC22	;VV1DOC V.7.1 -22-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-43. expratoms are numlit
	;       I-43.1  1E1*1.10
	;       I-43.2  92.36E-1*12.3E+1
	;       I-43.3  09900E-2*000.065432100
	;       I-43.4  0.123E2*12300E-2
	;     I-44. expratoms are strlit
	;       I-44.1  "AB2"*"2AB"
	;       I-44.2  "2A2B"*"2E2B"
	;     I-45. expratoms are lvn
	;       I-45.1  unsubscripted lvn
	;       I-45.2  subscripted lvn
	;
	;
	;Binary operators -1.4- (+, -, *, /, #, \(integer division))
	;     (V1BOA4)
	;
	;     algebraic quotient
	;
	;     I-46. expratom=0
	;       I-46.1  0/1
	;       I-46.2  0/-6
	;     I-47. left expratom>0, right expratom>0
	;       I-47.1  3/3
	;       I-47.2  8/2
	;       I-47.3  3/2
	;       I-47.4  3/4
	;       I-47.5  10/4
	;       I-47.6  .5/0.5
	;       I-47.7  4.1/0.01
	;     I-48. left expratom>0, right expratom<0
	;       I-48.1  11/-4
	;       I-48.2  .3/-0.3
	;       I-48.3  016.1370/-01.630
	;       I-48.4  0.0618700/-026.90
	;     I-49. left expratom<0, right expratom>0
	;       I-49.1  -9/4
	;       I-49.2  -597.5/25
	;       I-49.3  -0.9191799/999.0
	;     I-50. left expratom<0, right expratom<0
	;       I-50.1  -12/-4
	;       I-50.2  -50.3/-0.25
	;       I-50.3  -00.00404/-0.10100
	;     I-51. expratoms are numlit
	;       I-51.1  1E1/1.60
	;       I-51.2  64777779E-07/0.099E+3
