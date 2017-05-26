VV1DOC27	;VV1DOC V.7.1 -27-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-77.10  .3E1'<00400E-2
	;       I-77.11  -.3E01'<4E0
	;       I-77.12  -5'<-4
	;     I-78. expratoms are numlit and strlit
	;       I-78.1  0'<"0"
	;       I-78.2  0'<"00"
	;       I-78.3  3.1'<"3.2"
	;       I-78.4  3.1'<"-3.0"
	;       I-78.5  3.1'<"+3.2E+5"
	;       I-78.6  0010000.000'<"00099.2e+500"
	;       I-78.7  00.01'<"00000.100000000000000"
	;       I-78.8  30.10'<"30.1"
	;     I-79. expratoms are strlit and numlit
	;       I-79.1  "3A"'<4
	;       I-79.2  "3.1"'<3.2
	;       I-79.3  "3E1"'<31
	;       I-79.4  "'0"'<.023
	;       I-79.5  "-10"'<-5
	;       I-79.6  "3.1"'<3.1
	;     I-80. expratoms are strlit and strlit
	;       I-80.1  "3A"'<"4"
	;       I-80.2  -"3E1A"'<+"30.01A"
	;       I-80.3  +"3A"'<"4"
	;       I-80.4  "3E1A"'<"30.01E-"
	;       I-80.5  "+3A"'<"2"
	;       I-80.6  "987654A"'<"987654E"
	;       I-80.7  "QWERTY"'<"ZXY30"
	;     I-81. empty string on left side
	;       I-81.1  ""'<3
	;       I-81.2  ""'<0
	;       I-81.3  ""'<"-.03"
	;       I-81.4  ""'<"+.03"
	;     I-82. empty string on right side
	;       I-82.1  3'<""
	;       I-82.2  0'<""
	;       I-82.3  -3'<""
	;     I-83. empty string on both sides
	;
	;
	;Binary operators -2.3- (<, >, =, [, ])
	;     (V1BOB3)
	;
	;     numeric greater than (>)
	;
	;     I-84. expratoms are numlit and numlit
