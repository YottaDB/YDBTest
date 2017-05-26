V1FNF3	;FUNCTION $FIND -3-;YS-TS,V1FN,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1FNF3: TEST OF $FIND FUNCTION -3-"
	W !!,"$FIND(expr1,expr2,intexpr3)",!
297	W !,"I-297  intexpr3<0"
	S ITEM="I-297.1  expr1 contains expr2",VCOMP=$FIND("ABCBC","BC",-2) S VCORR=4 D EXAMINER
	S ITEM="I-297.2  expr2 is empty string",VCOMP=$FIND("ABCBC","",-12) S VCORR=1 D EXAMINER
	S ITEM="I-297.3  expr1 and expr2 are empty string" S VCOMP=$F("","",-10.2) S VCORR=1 D EXAMINER
	S ITEM="I-297.4  expr1 is empty string",VCOMP=$F("","power",-10.2),VCORR=0 D EXAMINER
	;
298	W !,"I-298  intexpr3=0"
	S ITEM="I-298.1  $L(expr1)>$L(expr2)",VCOMP=$F("abcdefghijkl","cdef",0) S VCORR=7 D EXAMINER
	S ITEM="I-298.2  $L(expr1)<$L(expr2)" S VCOMP=$F("ABC","ABCD",0) S VCORR=0 D EXAMINER
	S ITEM="I-298.3  expr2 is empty string" S VCOMP=$F("ABC","",0) S VCORR=1 D EXAMINER
	S ITEM="I-298.4  expr1 and expr2 are empty string",VCOMP=$F("","",0),VCORR=1 D EXAMINER
	S ITEM="I-298.5  expr1 is empty string" S VCOMP=$F("",1232,0) S VCORR=0 D EXAMINER
	;
299	W !,"I-299  0<intexpr3 and intexpr3'>$L(expr1)"
	S ITEM="I-299.1  intexpr3=1" S VCOMP=$F("ABC","BC",1) S VCORR=4 D EXAMINER
	S ITEM="I-299.2  $E(expr1,intexpr3,intexpr3+$L(expr2)-1)=expr2",VCOMP=$F("ABCdef","BCd",2),VCORR=5 D EXAMINER
	S ITEM="I-299.3  intexpr3=$L(expr1)",VCOMP=$F("ABC","BC",3),VCORR=0 D EXAMINER
	S ITEM="I-299.4  expr2 is empty string",VCOMP=$F("ABC","",2),VCORR=2 D EXAMINER
	;
300	W !,"I-300  intexpr3>$LENGTH(expr1)"
	S ITEM="I-300.1  $L(expr1)>$L(expr2)>1" S VCOMP=$F("ABCBC","BC",6) S VCORR=0 D EXAMINER
	S ITEM="I-300.2  expr2 is empty string",VCOMP=$F("ABC","",8.1),VCORR=8 D EXAMINER
	S ITEM="I-300.3  expr2 is empty string and intexpr3>255" S VCOMP=$F("ABC","",900.5) S VCORR=900 D EXAMINER
	S ITEM="I-300.4  expr1 and expr2 are empty string",VCOMP=$F("","",8.1) S VCORR=8 D EXAMINER
	;
301	W !,"I-301  expr1 contains more than one expr2's and intexpr3'>$F(expr1,expr2)"
	S ITEM="I-301  ",VCOMP=$F("ABCBC","BC",3),VCORR=6 D EXAMINER
	;
302	W !,"I-302  expr1 contains more than one expr2's and intexpr3>$F(expr1,expr2)"
	S ITEM="I-302  ",VCOMP=$F("ABCBC","BC",12),VCORR=0 D EXAMINER
	;
END	W !!,"END OF V1FNF3",!
	S ROUTINE="V1FNF3",TESTS=19,AUTO=19,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
