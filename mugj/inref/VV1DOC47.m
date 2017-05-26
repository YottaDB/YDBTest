VV1DOC47	;VV1DOC V.7.1 -47-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-614. lvn is "%" followed by alpha and digit
	;     I-615. lvn is alpha
	;       I-615.1  A
	;       I-615.2  AB
	;       I-615.3  ABCD
	;       I-615.4  ABCDEF
	;       I-615.5  ABCDEFG
	;     I-616. lvn is combination of alpha and digit
	;       I-616.1  Q00
	;       I-616.2  Z1Y2X3
	;       I-616.3  Q000000A
	;     I-617. maximum length of lvn
	;     I-618. 8 levels depth of subscript
	;       I-618.1  1 level depth of subscript
	;       I-618.2  ABCDEFGH(1,2,3,4,5,6,7,8)
	;       I-618.3  %1X2Y3Z(1,10,100,12,123,2,01)
	;
	;
	;Global variable name
	;     (V1GVN)
	;
	;     I-393. gvn is the character "%"
	;     I-394. gvn is % followed by alpha
	;     I-395. gvn is % followed by digit
	;     I-396. gvn is % followed by alpha and digit
	;       I-396.1  gvn is % followed by a alpha and a digit
	;       I-396.2  gvn is % followed by alphas and digits
	;     I-397. gvn is alpha
	;     I-398. gvn is alpha and digit
	;       I-398.1  ^V1
	;       I-398.2  ^V1A
	;       I-398.3  ^V100
	;       I-398.4  ^V1AB
	;       I-398.5  ^V1Z1Y2X
	;       I-398.6  ^V1ABCDE
	;     I-399. Maximum length of gvn
	;       I-399.1  gvn is ^V1ABCDEF
	;       I-399.2  ^V100000A
	;     I-400. 8 levels depth subscript
	;       I-400.1  1 level depth subscript
	;       I-400.2  8 levels depth subscript
	;       I-400.3  gvn is ^%1X2Y3Z(1,1,1,1,1,1,1,1)
	;
	;
	;
