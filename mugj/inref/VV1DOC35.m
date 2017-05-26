VV1DOC35	;VV1DOC V.7.1 -35-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-127.1  987]"987"
	;       I-127.2  3.1]"3.1ABD"
	;       I-127.3  22.56]"22$56"
	;       I-127.4  99.2]" ! "
	;       I-127.5  -099.2]"-9 ! "
	;     I-128. expratoms are strlit and numlit
	;       I-128.1  "3"]3
	;       I-128.2  "3A"]3
	;       I-128.3  "00123"]1
	;       I-128.4  "ABCD"]1
	;       I-128.5  "!"""]0231
	;       I-128.6  +"3E-2A"]-3
	;     I-129. expratoms are strlit and strlit
	;       I-129.1  "A"]"A"
	;       I-129.2  "AB"]"A"
	;       I-129.3  "ABC"]"ABC"
	;       I-129.4  "AAA"]"AA"
	;       I-129.5  -"3A"]"-"
	;       I-129.6  "AA"]"AAA"
	;       I-129.7  "AAA"]"aaa"
	;       I-129.8  "aaa"]"AAA"
	;     I-130. empty string on left side
	;       I-130.1  ""]"A"
	;       I-130.2  ""]".1234"
	;     I-131. empty string on right side
	;       I-131.1  "A"]""
	;       I-131.2  "%AND"]""
	;     I-132. empty string on both sides
	;
	;
	;Binary operators -2.10- (<, >, =, [, ])
	;     (V1BOB10)
	;
	;     string not follows ('])
	;
	;     I-133. expratoms are numlit and numlit
	;       I-133.1  123']1
	;       I-133.2  3.0']3
	;       I-133.3  00123']1
	;       I-133.4  00.34']0
	;       I-133.5  1234']124
	;       I-133.6  98788.34']987880
	;       I-133.7  98788.34']987
	;     I-134. expratoms are numlit and strlit
	;       I-134.1  987']"987"
