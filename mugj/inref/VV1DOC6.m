VV1DOC6	;VV1DOC V.7.1 -6-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-186. Comment coming after ls
	;     I-187. Comment coming after label ls
	;     I-188. Comment coming after command argument
	;     I-189. Comment coming after argumentless command with postconditional
	;     I-190. Comment coming after argumentless command without postconditional
	;
	;
	;Line label -1-
	;     (V1LL1)
	;
	;     I-609. the first line is labelless
	;     I-601. labelless line
	;     I-602. label is "%"
	;     I-603. label is "%" and alpha
	;       I-603.1  %A
	;       I-603.2  %ABZWQ
	;       I-603.3  %ABCDE
	;     I-604. label is "%" and digit
	;       I-604.1  %01
	;       I-604.2  %000000
	;     I-605. label is "%" and combination of alpha and digit
	;       I-605.1  %09A
	;       I-605.2  %09AB
	;       I-605.3  %ABC000
	;       I-605.4  %ABC0000
	;       I-605.5  %234EFGH
	;
	;
	;Line label -1-
	;     (V1LL1)
	;
	;     I-606. label is alpha
	;       I-606.1  A
	;       I-606.2  AB
	;       I-606.3  ABC
	;       I-606.4  ABCD
	;       I-606.5  ABCDE
	;       I-606.6  ABCDEF
	;       I-606.7  ABCDEFG
	;       I-606.8  ABCDEFGH
	;     I-607. label is intlit
	;       I-607.1  3
	;       I-607.2  00
	;       I-607.3  123
	;       I-607.4  1234
