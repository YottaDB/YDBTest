VV1DOC34	;VV1DOC V.7.1 -34-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-119.6  23.459876'[0.45980
	;       I-119.7  -0.456'[-0.
	;     I-120. expratoms are numlit and strlit
	;       I-120.1  3.0'["."
	;       I-120.2  3.0'["0"
	;       I-120.3  -3'["-"
	;       I-120.4  3E1'["E"
	;       I-120.5  -0.456'["-."
	;       I-120.6  -0.456E+2'["+"
	;       I-120.7  456E-5'["."
	;     I-121. expratoms are strlit and numlit
	;       I-121.1  "00123"'[0
	;       I-121.2  "00123"'[13
	;       I-121.3  "T-114 "'[0114.0
	;       I-121.4  "HELP2191-1101191HELP"'[1191
	;       I-121.5  "2//211001021202003"'[2E2
	;     I-122. expratoms are strlit and strlit
	;       I-122.1  "A"'["A"
	;       I-122.2  "AB"'["A"
	;       I-122.3  "A"'["BA"
	;       I-122.4  +"3A"'["A"
	;       I-122.5  "00123E-5"'["."
	;     I-123. empty string on left side
	;       I-123.1  ""'["A"
	;       I-123.2  ""'["123456"
	;     I-124. empty string on right side
	;       I-124.1  "A"'[""
	;       I-124.2  "ABC"'[""
	;     I-125. empty string on both sides
	;
	;
	;Binary operators -2.9- (<, >, =, [, ])
	;     (V1BOB9)
	;
	;     string follows (])
	;
	;     I-126. expratoms are numlit and numlit
	;       I-126.1  123]1
	;       I-126.2  3.0]3
	;       I-126.3  00123]1
	;       I-126.4  00.34]0
	;       I-126.5  1234]124
	;       I-126.6  98788.34]987880
	;       I-126.7  98788.34]987
	;     I-127. expratoms are numlit and strlit
