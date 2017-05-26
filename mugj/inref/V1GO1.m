V1GO1	;GOTO COMMAND (LOCAL BRANCHING) -1-;KO-TS,V1GO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0,ITEM=""
	W !!,"V1GO1: TEST OF GOTO COMMAND (LOCAL BRANCHING) -1-",!
	W !,"GOTO label",!
	W !,"I-382/383  label is % followed by alpha and digit"
	S ITEM="I-382/383.1  label is %",VCOMP="%"
	GOTO % S VCOMP=VCOMP_" E- % "
	S VCOMP=VCOMP_" E- % NEXT " D EXAMINER
	;
%	S VCORR="%" D EXAMINER
	S ITEM="I-382/383.2  label is % followed by a alpha",VCOMP="%A"
	GOTO %A
	S VCOMP=VCOMP_" E- "
	;
%90	S VCORR="%90" D EXAMINER
	S ITEM="I-382/383.6  label is % followed by 7 digits",VCOMP="%0000000"
	G %0000000
	;
%A	S VCORR="%A" D EXAMINER
	S ITEM="I-382/383.3  label is % followed by alphas",VCOMP="%ABCDEFG"
	G %ABCDEFG
	;
%2345678	S VCORR="%2345678" D EXAMINER
	S ITEM="I-382/383.8  label is % followed by combination of a alpha and a digit",VCOMP="%A1" G %A1
	;
%0	S VCORR="%0" D EXAMINER
	S ITEM="I-382/383.5  label is % followed by 2 digits",VCOMP="%90"
	G %90
	;
%ABCDEFG	S VCORR="%ABCDEFG" D EXAMINER
	S ITEM="I-382/383.4  label is % followed by a digit",VCOMP="%0"
	G %0
	;
%0000000	S VCORR="%0000000" D EXAMINER
	S ITEM="I-382/383.7  label is % followed by another 7 digits"
	S VCOMP="%2345678" G %2345678
	;
%A1	S VCORR="%A1" D EXAMINER
	S ITEM="I-382/383.9  label is % followed by combination of alphas and digits",VCOMP="%A1B2C3D"
	G %A1B2C3D
	;
%A1B2C3D	S VCORR="%A1B2C3D" D EXAMINER
	;
	W !,"I-380  label is alpha"
	S ITEM="I-380.1  label is a alpha",VCOMP="A" G A
	;
A	S VCORR="A" D EXAMINER S ITEM="I-380.2  label is different alpha",VCOMP="Q"
	G Q
	;
Z	S VCORR="Z" D EXAMINER S ITEM="I-380.4  label is 2 alphas",VCOMP="DO"
	G DO
	;
SET	S VCORR="SET" D EXAMINER
	S ITEM="I-380.8  label is 8 alphas",VCOMP="ABCDEFGH"
	G ABCDEFGH
	;
Q	S VCORR="Q" D EXAMINER S ITEM="I-380.3  label is different alpha",VCOMP="Z"
	G Z
	;
IF	S VCORR="IF" D EXAMINER S ITEM="I-380.6  label is 4 alphas",VCOMP="QUIT"
	G QUIT
	;
DO	S VCORR="DO" D EXAMINER S ITEM="I-380.5  label is another 2 alphas",VCOMP="IF"
	G IF
	;
ABCDEFGH	S VCORR="ABCDEFGH" D EXAMINER
	;
	W !,"I-381  label is intlit"
	S ITEM="I-381.1  0",VCOMP="0" G 0
0	S VCORR="0" D EXAMINER S ITEM="I-381.2  1",VCOMP="1" G 1
1	S VCORR="1" D EXAMINER S ITEM="I-381.3  01",VCOMP="01" G 01
10	S VCORR="10" D EXAMINER S ITEM="I-381.5  12",VCOMP="12" G 12
QUIT	S VCORR="QUIT" D EXAMINER S ITEM="I-380.7  label is 3 alphas",VCOMP="SET"
	G SET
100	S VCORR="100" D EXAMINER S ITEM="I-381.7  012",VCOMP="012" G 012
0012	S VCORR="0012" D EXAMINER S ITEM="I-381.9  92345678",VCOMP="92345678" G 92345678
01	S VCORR="01" D EXAMINER S ITEM="I-381.4  10",VCOMP="10" G 10
92345678	S VCORR="92345678" D EXAMINER S ITEM="I-381.10  00000000",VCOMP="00000000" G 00000000
12	S VCORR="12" D EXAMINER S ITEM="I-381.6  100",VCOMP="100" G 100
012	S VCORR="012" D EXAMINER S ITEM="I-381.8  0012",VCOMP="0012" G 0012
00000000	S VCORR="00000000" D EXAMINER
	;
	W !,"I-384  label is combination of alpha and digit"
	S ITEM="I-384.1  label is combination of a alpha and a digit",VCOMP="A1" G A1
	;
Z012	S VCORR="Z012" D EXAMINER
	S ITEM="I-384.3  label is combination of alphas and digits",VCOMP="ZXY987A0"
	G ZXY987A0
	;
A1	S VCORR="A1" D EXAMINER
	S ITEM="I-384.2  label is combination of a alpha and digits",VCOMP="Z012"
	G Z012
	;
ZXY987A0	S VCORR="ZXY987A0" D EXAMINER
	;
END	W !!,"END OF V1GO1",!
	S ROUTINE="V1GO1",TESTS=30,AUTO=30,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
