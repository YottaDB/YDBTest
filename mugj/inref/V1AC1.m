V1AC1	;$ASCII AND $CHAR FUNCTIONS -1-;YS-TS,V1AC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1AC1: TEST OF $CHAR FUNCTION",!
	W !,"$CHAR(L intexpr)",!
1	W !,"I-1  intexpr is checked for 32-126"
	S ITEM="I-1  ",VCOMP=""
	F I=32:1:126 SET VCOMP=VCOMP_$CHAR(I)
	S VCORR=" !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" D EXAMINER
	;
2	W !,"I-2  L intexpr is checked for 32-126"
	S ITEM="I-2  ",VCOMP="" F I=32:8:112 S VCOMP=VCOMP_$C(I,I+1,I+2,I+3,I+4,I+5,I+6,I+7)
	S I=120,VCOMP=VCOMP_$C(I,I+1,I+2,I+3,I+4,I+5,I+6)
	S VCORR=" !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" D EXAMINER
	;
3	W !,"I-3  Integer interpretation of intexpr, while intexpr is string literal"
	S ITEM="I-3  ",VCOMP=$C("65A","+66ABC",-"-67.3G1","68000E-3","71+10") S VCORR="ABCDG" D EXAMINER
	;
4	W !,"I-4  Integer interpretation of intexpr, while intexpr is numeric literal"
	S ITEM="I-4  ",VCOMP=$CHAR(0.0069E+4,35.2*2.001),VCORR="EF" D EXAMINER
	;
5	W !,"I-5  Integer interpretation of intexpr, while intexpr contains binaryop"
	S ITEM="I-5  ",VCOMP=$C(15+15+2,+"66ABC"--2-3,"6"_"6"),VCORR=" AB" D EXAMINER
	;
6	W !,"I-6  intexpr<0"
	S ITEM="I-6  " K VCOMP S VCOMP=$C(-1),A=-48
	S VCOMP=VCOMP_$C(-1.00002,-100,-255,-78.9,"-66",A),VCORR="" D EXAMINER
	;
7	W !,"I-7  The difference between $CHAR(0) and empty string"
	S ITEM="I-7.1  empty string",X="" S X=$C(0)
	I X="" S PASS=PASS+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	I X'="" S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	S ITEM="I-7.2  $LENGTH" S VCOMP=$L(X),VCORR=1 D EXAMINER
	S ITEM="I-7.3  value of $A" S VCOMP=$A(X),VCORR=0 D EXAMINER
	;
END	W !!,"END OF V1AC1",!
	S ROUTINE="V1AC1",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
