VV1DOC33	;VV1DOC V.7.1 -33-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-112.4  23.456[0.4
	;       I-112.5  28.4536[03.0
	;       I-112.6  23.459876[0.45980
	;       I-112.7  -0.456[-0.
	;     I-113. expratoms are numlit and strlit
	;       I-113.1  3.0["."
	;       I-113.2  3.0["0"
	;       I-113.3  -3["-"
	;       I-113.4  3E1["E"
	;       I-113.5  -0.456["-."
	;       I-113.6  -0.456E+2["+"
	;       I-113.7  456E-5["."
	;     I-114. expratoms are strlit and numlit
	;       I-114.1  "00123"[0
	;       I-114.2  "00123"[13
	;       I-114.3  "T-114 "[0114.0
	;       I-114.4  "HELP2191-1101191HELP"[1191
	;       I-114.5  "2//211001021202003"[2E2
	;     I-115. expratoms are strlit and strlit
	;       I-115.1  "A"["A"
	;       I-115.2  "A"["AB"
	;       I-115.3  "BA"["A"
	;       I-115.4  "ABC"["AB"
	;       I-115.5  +"3A"["A"
	;       I-115.6  "00123E-5"["."
	;     I-116. empty string on left side
	;       I-116.1  ""["A"
	;       I-116.2  ""["123456"
	;     I-117. empty string on right side
	;       I-117.1  "A"[""
	;       I-117.2  "ABC"[""
	;     I-118. empty string on both sides
	;
	;
	;Binary operators -2.8- (<, >, =, [, ])
	;     (V1BOB8)
	;
	;     string not contains ('[)
	;
	;     I-119. expratoms are numlit and numlit
	;       I-119.1  123'[2
	;       I-119.2  00123'[0
	;       I-119.3  3.0'[3
	;       I-119.4  23.456'[0.4
	;       I-119.5  28.4536'[03.0
