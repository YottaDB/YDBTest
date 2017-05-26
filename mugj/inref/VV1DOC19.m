VV1DOC19	;VV1DOC V.7.1 -19-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;         I-801.7.2  +-lvn (lvn=0)
	;         I-801.7.3  +'lvn (lvn=0)
	;         I-801.7.4  -+lvn (lvn=0)
	;         I-801.7.5  --lvn (lvn=0)
	;         I-801.7.6  -'lvn (lvn=0)
	;         I-801.7.7  '+lvn (lvn=0)
	;         I-801.7.8  '-lvn (lvn=0)
	;         I-801.7.9  ''lvn (lvn=0)
	;         I-801.7.10  ++lvn
	;         I-801.7.11  +-lvn
	;         I-801.7.12  +'lvn
	;         I-801.7.13  -+lvn
	;         I-801.7.14  --lvn
	;         I-801.7.15  -'lvn
	;         I-801.7.16  '+lvn
	;         I-801.7.17  '-lvn
	;         I-801.7.18  ''lvn
	;
	;
	;Binary operators -1.1- (+, -, *, /, #, \(integer division))
	;     (V1BOA1)
	;
	;     algebraic sum
	;
	;     I-22. expratom=0
	;       I-22.1  0+0
	;       I-22.2  000000+0000
	;       I-22.3  100+0
	;       I-22.4  0+2.0
	;       I-22.5  00+-98.0010
	;       I-22.6  -0.0980010+0
	;     I-23. left expratom>0, right expratom>0
	;       I-23.1  2+3
	;       I-23.2  0.5+0.5
	;       I-23.3  0.3+0.300
	;       I-23.4  0.01000+4
	;       I-23.5  50.03000+4
	;     I-24. left expratom>0, right expratom<0
	;       I-24.1  5+-2
	;       I-24.2  0.3+-0.3
	;       I-24.3  10.1+-25
	;       I-24.4  0.99+-0.34
	;     I-25. left expratom<0, right expratom>0
	;       I-25.1  -1+5
	;       I-25.2  -597.2+25
