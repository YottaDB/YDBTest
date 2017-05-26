VV1DOC26	;VV1DOC V.7.1 -26-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-71.4  0010000.000<"00099.2e+500"
	;       I-71.5  00.01<"00000.1000000000000000"
	;       I-71.6  3.1<"3.1WQWEQWQWQWQWWQ"
	;     I-72. expratoms are strlit and numlit
	;       I-72.1  "3A"<4
	;       I-72.2  "3.1"<3.2
	;       I-72.3  "3E1"<31
	;       I-72.4  "'0"<.023
	;       I-72.5  "-10"<-5
	;       I-72.6  "3.1"<3.1
	;     I-73. expratoms are strlit and strlit
	;       I-73.1  "3A"<"4"
	;       I-73.2  -"3E1A"<+"30.01A"
	;       I-73.3  +"3A"<"4"
	;       I-73.4  "3E1A"<"30.01E-"
	;       I-73.5  "+3A"<"2"
	;       I-73.6  "+30A"<"30"
	;       I-73.7  "QWERTY"<"ZXY30"
	;     I-74. empty string on left side
	;       I-74.1  ""<3
	;       I-74.2  ""<0
	;       I-74.3  ""<"-.03"
	;       I-74.4  ""<"+.03"
	;     I-75. empty string on right side
	;       I-75.1  3<""
	;       I-75.2  0<""
	;       I-75.3  -3<""
	;     I-76. empty string on both sides
	;
	;
	;Binary operators -2.2- (<, >, =, [, ])
	;     (V1BOB2)
	;
	;     numeric not less than ('<)
	;
	;     I-77. expratoms are numlit and numlit
	;       I-77.1  0'<0
	;       I-77.2  0'<3
	;       I-77.3  3'<0
	;       I-77.4  3'<3
	;       I-77.5  3'<4
	;       I-77.6  -3'<0
	;       I-77.7  -3'<-4
	;       I-77.8  4'<3.0
	;       I-77.9  -4.1'<3
