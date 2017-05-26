VV1DOC31	;VV1DOC V.7.1 -31-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-101.3  "ABCDE"="ABCDZ"
	;       I-101.4  "+23.0"="23"
	;       I-101.5  "ABCDEFG"="ABCDEFG"
	;       I-101.6  "ABCDEFGHIJKL"="ABCDEFGHIJL"
	;       I-101.7  "987654321098765432109876543210"="98765432109876543210987654321"
	;       I-101.8  "0987654321098765432109876543210"="987654321098765432109876543210"
	;       I-101.9  "987654321098765432109876543210"="987654321098765432109876543210"
	;     I-102. empty string on left side
	;       I-102.1  ""="A"
	;       I-102.2  ""=0
	;       I-102.3  ""=1
	;       I-102.4  ""="#$%&"
	;     I-103. empty string on right side
	;       I-103.1  "Z"=""
	;       I-103.2  0=""
	;       I-103.3  .1=""
	;       I-103.4  +"^^^^"=""
	;     I-104. empty string on both sides
	;
	;
	;Binary operators -2.6.1- (<, >, =, [, ])
	;     (V1BOB6A)
	;
	;     string not identical ('=)
	;
	;     I-105. expratoms are numlit and numlit
	;       I-105.1  30'=30
	;       I-105.2  3E2'=300
	;       I-105.3  3.000'=0003
	;       I-105.4  00000.100000'=.1
	;       I-105.5  0009E-3'=0.00900000
	;       I-105.6  222.21'=222.201
	;       I-105.7  00.03000E+000003'=30
	;       I-105.8  0'=000.00000E-03
	;       I-105.9  0'=00000
	;     I-106. expratoms are numlit and strlit
	;       I-106.1  3'="3"
	;       I-106.2  98765'="98765.0"
	;       I-106.3  .1'="0.1"
	;       I-106.4  0.1'="0.1"
	;       I-106.5  0.1'=".1"
	;       I-106.6  98765'=-"-98765.0"
	;       I-106.7  00'="00"
	;     I-107. expratoms are strlit and numlit
	;       I-107.1  "3A"'=3
