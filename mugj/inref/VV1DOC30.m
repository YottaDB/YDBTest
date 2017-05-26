VV1DOC30	;VV1DOC V.7.1 -30-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;    string identity (=)
	;
	;     I-98. expratoms are numlit and numlit
	;       I-98.1  30=30
	;       I-98.2  3E2=300
	;       I-98.3  3.000=0003
	;       I-98.4  -0.1=-.1
	;       I-98.5  9E-3=.009
	;       I-98.6  222.21=222.201
	;       I-98.7  00.03000E+3=30
	;       I-98.8  -0=0.00000E+3
	;       I-98.9  0=00000
	;       I-98.10  30=000020
	;     I-99. expratoms are numlit and strlit
	;       I-99.1  3="3"
	;       I-99.2  98765="98765.0"
	;       I-99.3  .1="0.1"
	;       I-99.4  0.1="0.1"
	;       I-99.5  0.1=".1"
	;       I-99.6  98765=-"-98765.0"
	;       I-99.7  00="00"
	;       I-99.8  3.10="3.1E-00"
	;       I-99.9  3100="000003.1000E+003"
	;     I-100. expratoms are strlit and numlit
	;       I-100.1  "3A"=3
	;       I-100.2  "0.1"=.1
	;       I-100.3  "0.1"=0.1
	;       I-100.4  ".1"=0.1
	;       I-100.5  ".1"=.1
	;       I-100.6  "-3.1"=-3.1
	;       I-100.7  "3E1"=30
	;       I-100.8  +"3A"=3
	;       I-100.9  +-+-++"3E1A"=30
	;       I-100.10  "00"=00
	;       I-100.11  "3.1E-00"=3.1
	;       I-100.12  "3.1E-003"=.0031
	;       I-100.13  -"3A"=-3
	;
	;
	;Binary operators -2.5.2- (<, >, =, [, ])
	;     (V1BOB5B)
	;
	;     I-101. expratoms are strlit and strlit
	;       I-101.1  "A"="A"
	;       I-101.2  "A"="B"
