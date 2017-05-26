VV1DOC29	;VV1DOC V.7.1 -29-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     numeric not greater than ('>)
	;
	;     I-91. expratoms are numlit and numlit
	;       I-91.1  3'>3
	;       I-91.2  4'>3
	;       I-91.3  0'>0
	;       I-91.4  0'>3
	;       I-91.5  3'>0
	;       I-91.6  -3'>0
	;       I-91.7  -3'>-4
	;       I-91.8  4'>3.0
	;       I-91.9  -4.1'>3
	;       I-91.10  .3E1'>00400E-2
	;       I-91.11  .3E01'>-4E0
	;     I-92. expratoms are numlit and strlit
	;       I-92.1  2'>"9Q"
	;       I-92.2  30.1'>"3E+1"
	;       I-92.3  30.1'>"30.+999DG"
	;       I-92.4  30.1'>"20+589"
	;       I-92.5  20'>"-3E+1"
	;     I-93. expratoms are strlit and numlit
	;       I-93.1  "3A"'>2
	;       I-93.2  "3E1"'>29
	;       I-93.3  "3.1"'>3.0
	;       I-93.4  "2.99"'>3.0
	;       I-93.5  "-87.01E-1"'>-98710
	;     I-94. expratoms are strlit and strlit
	;       I-94.1  "3A"'>"2"
	;       I-94.2  "3E1A"'>"029.9A"
	;       I-94.3  "-23ENGLISH"'>"-22.00e-9"
	;     I-95. empty string on left side
	;       I-95.1  ""'>9
	;       I-95.2  ""'>0
	;       I-95.3  ""'>-9
	;       I-95.4  ""'>"-9FIND"
	;     I-96. empty string on right side
	;       I-96.1  2'>""
	;       I-96.2  0'>""
	;       I-96.3  -2.2'>""
	;     I-97. empty string on both sides
	;
	;
	;Binary operators -2.5.1- (<, >, =, [, ])
	;     (V1BOB5A)
	;
