VV1DOC25	;VV1DOC V.7.1 -25-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-66. left expratom<0, right expratom<0
	;       I-66.1  -1#-4
	;       I-66.2  -2#-4
	;       I-66.3  -3#-4
	;       I-66.4  -4#-4
	;       I-66.5  -5#-4
	;       I-66.6  -6#-4
	;       I-66.7  -7#-4
	;       I-66.8  -8#-4
	;       I-66.9  -50.3#-0.25
	;     I-67. expratoms are numlit
	;       I-67.1  1E1#1.10
	;       I-67.2  923.6E-1#.1236E+1
	;       I-67.3  00023.E3#00.980000E-2
	;       I-67.4  0.123E2#12300E-2
	;     I-68. expratoms are strlit
	;       I-68.1  "AB2"#"2AB"
	;       I-68.2  "2A2B"#"2E2B"
	;     I-69. expratoms are lvn
	;       I-69.1  unsubscripted lvn
	;       I-69.2  subscripted lvn
	;
	;
	;Binary operators -2.1- (<, >, =, [, ])
	;     (V1BOB1)
	;
	;     numeric less than (<)
	;
	;     I-70. expratoms are numlit and numlit
	;       I-70.1  0<0
	;       I-70.2  0<3
	;       I-70.3  3<0
	;       I-70.4  3<3
	;       I-70.5  3<4
	;       I-70.6  -3<0
	;       I-70.7  -3<-4
	;       I-70.8  4<3.0
	;       I-70.9  -4.1<3
	;       I-70.10  .3E1<00400E-2
	;       I-70.11  -.3E01<4E0
	;       I-70.12  -5<-4
	;     I-71. expratoms are numlit and strlit
	;       I-71.1  3.1<"3.2"
	;       I-71.2  3.1<"-3.0"
	;       I-71.3  3.1<"+3.2E+5"
