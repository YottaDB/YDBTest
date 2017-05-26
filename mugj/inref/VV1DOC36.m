VV1DOC36	;VV1DOC V.7.1 -36-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-134.2  3.1']"3.1ABD"
	;       I-134.3  22.56']"22$56"
	;       I-134.4  99.2']" ! "
	;       I-134.5  -099.2']"-9 ! "
	;     I-135. expratoms are strlit and numlit
	;       I-135.1  "3"']3
	;       I-135.2  "3A"']3
	;       I-135.3  "00123"']1
	;       I-135.4  "ABCD"']1
	;       I-135.5  "!"""']0231
	;       I-135.6  +"3E-2A"']-3
	;     I-136. expratoms are strlit and strlit
	;       I-136.1  "B"']"A"
	;       I-136.2  ")"']"("
	;       I-136.3  "#"']"A"
	;       I-136.4  "A"']"A"
	;       I-136.5  "AB"']"A"
	;       I-136.6  "ABC"']"ABC"
	;       I-136.7  "AAA"']"AA"
	;       I-136.8  -"3A"']"-"
	;       I-136.9  "AA"']"AAA"
	;       I-136.10  "AAA"']"aaa"
	;       I-136.11  "aaa"']"AAA"
	;     I-137. empty string on left side
	;       I-137.1  ""']"A"
	;       I-137.2  ""']".1234"
	;     I-138. empty string on right side
	;       I-138.1  "A"']""
	;       I-138.2  "%AND"']""
	;     I-139. empty string on both sides
	;
	;
