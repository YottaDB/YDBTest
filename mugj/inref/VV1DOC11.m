VV1DOC11	;VV1DOC V.7.1 -11-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Interpretation of expr to numeric literal -4-
	;     (V1NUM4)
	;
	;     I-668. interpretation of "head" of string literal
	;       I-668.1  .$
	;       I-668.2  - 1
	;       I-668.3  543.QWERTY
	;       I-668.4  00098765432NUMLIT
	;       I-668.5  987600.0000END
	;       I-668.6  4560.023000000DOIT
	;       I-668.7  76540E0000002 999
	;       I-668.8  000.0056800E4GOLD
	;       I-668.9  00.02350E7SEASON
	;       I-668.10  067.8900000E00000ZERO
	;       I-668.11  098765E-10"99
	;       I-668.12  8594E-3
	;       I-668.13  102.030E+02
	;       I-668.14  10.20.34
	;       I-668.15  --234.5
	;       I-668.16  .-23
	;       I-668.17  -."
	;       I-668.18  -1-5
	;       I-668.19  45.6300E-ABV
	;       I-668.20  3455E2.4
	;       I-668.21  234E++2
	;       I-668.22  120.02000E--3
	;       I-668.23  1234e2
	;       I-668.24  0000007D2
	;       I-668.25  879F+3
	;       I-668.26  .  23
	;       I-668.27  000087:123
	;       I-668.28  876,897
	;       I-668.29  ""
	;       I-668.30  ONE
	;       I-668.31  $1.502
	;
	;
	;Format control characters -1-
	;     (V1FC1)
	;
	;     I-248. parameters occur in a single instance of format
	;     I-249. "New line" operation by !
	;     I-250. "Top of page" operation by #
	;     I-251. Effect of comma in WRITE command
	;     I-252. Effect of comma between "new line operator" (!)
