VV1DOC28	;VV1DOC V.7.1 -28-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-84.1  0>0
	;       I-84.2  0>3
	;       I-84.3  3>0
	;       I-84.4  3>3
	;       I-84.5  4>3
	;       I-84.6  -3>0
	;       I-84.7  -3>-4
	;       I-84.8  4>3.0
	;       I-84.9  -4.1>3
	;       I-84.10  .3E1>00400E-2
	;       I-84.11  .3E01>-4E0
	;       I-84.12  -95.00001>-95
	;     I-85. expratoms are numlit and strlit
	;       I-85.1  2>"9Q"
	;       I-85.2  30.1>"3E+1"
	;       I-85.3  30.1>"30.+999DG"
	;       I-85.4  30.1>"20+589"
	;       I-85.5  20>"-3E+1"
	;       I-85.6  30.1>"30.1"
	;       I-85.7  -30.1>"-30.1"
	;       I-85.8  -987.0456>"-87.56"
	;       I-85.9  -987.0456>"-8787.56"
	;     I-86. expratoms are strlit and numlit
	;       I-86.1  "3A">2
	;       I-86.2  "3E1">29
	;       I-86.3  "3.1">3.0
	;       I-86.4  "2.99">3.0
	;       I-86.5  "-87.01E-1">-98710
	;     I-87. expratoms are strlit and strlit
	;       I-87.1  "3A">"2"
	;       I-87.2  +"3E1A">"029.9A"
	;       I-87.3  "-23ENGLISH">"-22.00e-9"
	;     I-88. empty string on left side
	;       I-88.1  "">9
	;       I-88.2  "">0
	;       I-88.3  "">-9
	;       I-88.4  "">"-9FIND"
	;     I-89. empty string on right side
	;       I-89.1  2>""
	;       I-89.2  0>""
	;       I-89.3  -2.2>""
	;     I-90. empty string on both sides
	;
	;Binary operators -2.4- (<, >, =, [, ])
	;     (V1BOB4)
