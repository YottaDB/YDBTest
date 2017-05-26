V1FNF2	;FUNCTION $FIND -2-;YS-TS,V1FN,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1FNF2: TEST OF $FIND FUNCTION -2-"
290	W !,"I-290  expr1 is numeric literal and does not contains expr2"
	S ITEM="I-290.1  expr1 is numlit",VCOMP=$F(123.000,0),VCORR=0 D EXAMINER
	S ITEM="I-290.2  expr1 is another numlit" S VCOMP=$F(001234.000,"0123"),VCORR=0 D EXAMINER
	;
291	W !,"I-291  expr1 is non-integer numeric literal"
	S ITEM="I-291.1  expr1 is numlit" S VCOMP=$F(00123.45000,03.40),VCORR=6 D EXAMINER
	S ITEM="I-291.2  expr1 is another numlit" S VCOMP=$F(00123.456000E2,"34") S VCORR=5 D EXAMINER
	;
292	W !,"I-292  expr1 contains more than one expr2's"
	S ITEM="I-292.1  $L(expr2)>1" S VCOMP=$F("ABCBC","BC") S VCORR=4 D EXAMINER
	S ITEM="I-292.2  another" S VCOMP=$F("ABACDbcBBCDBCD","BC") S VCORR=11 D EXAMINER
	S ITEM="I-292.3  $L(expr2)=1" S VCOMP=$F("bABCBC","B") S VCORR=4 D EXAMINER
	;
293	W !,"I-293  expr1 is non-integer numeric and expr is ""."" or ""-"""
	S ITEM="I-293.1  expr1 is mant" S VCOMP=$F(00123.123000,".") S VCORR=5 D EXAMINER
	S ITEM="I-293.2  expr1 is mant exp" S VCOMP=$F(123.456000E-1,".") S VCORR=4 D EXAMINER
	S ITEM="I-293.3  expr1 is negative non-integer numlit" S VCOMP=$F(-00123.45000E-3,"-") S VCORR=2 D EXAMINER
	;
294	W !,"I-294.1  expr1 is empty string"
	S ITEM="I-294.1  expr1 is strlit" S VCOMP=$FIND("","E") S VCORR=0 D EXAMINER
	S ITEM="I-294.2  expr1 is lvn" S A="",VCOMP=$F(A,0.0001) S VCORR=0 D EXAMINER
	;
295	W !,"I-295  expr2 is empty string"
	S ITEM="I-295.1  expr2 is strlit" S VCOMP=$F(9876,"") S VCORR=1 D EXAMINER
	S ITEM="I-295.2  expr2 is lvn" S A="A",B="",VCOMP=$F(A,B) S VCORR=1 D EXAMINER
	;
296	W !,"I-296  Both expr1 and expr2 are empty string"
	S ITEM="I-296.1  Both expr1 and expr2 are strlit" S VCOMP=$F("","") S VCORR=1 D EXAMINER
	S ITEM="I-296.2  Both expr1 and expr2 are lvn" S A="",VCOMP=$F(A,A) S VCORR=1 D EXAMINER
	;
847	W !,"I-847 $F(expr1,expr2)=256  ;boundary"
	S A="" F I=1:1:250 S A=A_"A"
	S A=A_"BBBBB"
	S ITEM="I-847.1  $F=255" S VCOMP=$F(A,"BBBB"),VCORR=255 D EXAMINER
	;
	S ITEM="I-847.2  $F=256" S VCOMP=$F(A,"BBBBB"),VCORR=256 D EXAMINER
	;
END	W !!,"END OF V1FNF2",!
	S ROUTINE="V1FNF2",TESTS=18,AUTO=18,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
