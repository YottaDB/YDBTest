VV1DOC32	;VV1DOC V.7.1 -32-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-107.2  "0.1"'=.1
	;       I-107.3  "0.1"'=0.1
	;       I-107.4  ".1"'=0.1
	;       I-107.5  ".1"'=.1
	;       I-107.6  "3.1"'=3.1
	;       I-107.7  "3E1"'=30
	;       I-107.8  +"3A"'=3
	;       I-107.9  +-+-++"3E1A"'=30
	;       I-107.10  "00"'=00
	;
	;
	;Binary operators -2.6.2- (<, >, =, [, ])
	;     (V1BOB6B)
	;
	;     I-108. expratoms are strlit and strlit
	;       I-108.1  "AB"'="AB"
	;       I-108.2  "AB"'="ABV"
	;       I-108.3  "ABCDE"'="ABCDZ"
	;       I-108.4  "+23.0"'="23"
	;       I-108.5  "ABCDEFG"'="ABCDEFG"
	;       I-108.6  "ABCDEFGHIJKL"'="ABCDEFGHIJL"
	;       I-108.7  "987654321098765432109876543210"'="98765432109876543210987654321"
	;       I-108.8  "0987654321098765432109876543210"'="987654321098765432109876543210"
	;       I-108.9  "987654321098765432109876543210"'="987654321098765432109876543210"
	;     I-109. empty string on left side
	;       I-109.1  ""'=1
	;       I-109.2  ""'=0
	;       I-109.3  ""'="****"
	;     I-110. empty string on right side
	;       I-110.1  1'=""
	;       I-110.2  0'=""
	;       I-110.3  "@#$"'=""
	;     I-111. empty string on both sides
	;
	;
	;Binary operators -2.7- (<, >, =, [, ])
	;     (V1BOB7)
	;
	;     string contains ([)
	;
	;     I-112. expratoms are numlit and numlit
	;       I-112.1  123[2
	;       I-112.2  00123[0
	;       I-112.3  3.0[3
