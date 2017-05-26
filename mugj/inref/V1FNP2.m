V1FNP2	;FUNCTION $PIECE -2-;YS-TS,V1FN,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1FNP2: TEST OF $PIECE FUNCTION -2-",!
325	W !,"I-325  expr1 is non-intexpr numeric literal"
	S ITEM="I-325  " S VCOMP=$P(123.5,3,1) S VCORR=12 D EXAMINER
	;
326	W !,"I-326  expr1 is empty string"
	S ITEM="I-326  " S VCOMP=$P("","B",2) S VCORR="" D EXAMINER
	;
327	W !,"I-327  expr2 is empty string"
	S ITEM="I-327  " S VCOMP=$P("ABCBD","",2) S VCORR="" D EXAMINER
	;
328	W !,"I-328  expr1 are expr2 are empty string"
	S ITEM="I-328  " S VCOMP=$P("","",2) S VCORR="" D EXAMINER
	;
329	W !,"I-329  expr2 is numeric literal"
	S ITEM="I-329  " S VCOMP=$P("12.34.56.78.89.90",-000.1,3.1) S VCORR="" D EXAMINER
	;
330	W !,"I-330  expr2 contains operators"
	S ITEM="I-330.1  concatenation operator",VCOMP=$P("ABCBCDBC","B"_"C",2),VCORR="" D EXAMINER
	S ITEM="I-330.2  another concatenation operator",VCOMP=$P("AB CBbcBBC    BC DBC","B"_"C",2),VCORR="    " D EXAMINER
	S ITEM="I-330.3  + binary operators",VCOMP=$P(9139191,80+9+2,2.2),VCORR="3" D EXAMINER
	;
	W !!,"$PIECE(expr1,expr2,intexpr3,intexpr4)",!
331	W !,"I-331  intexpr4 is positive integer"
	S ITEM="I-331.1  intexpr3<intexpr4" S VCOMP=$P("ABCBD","B",2,3) S VCORR="CBD" D EXAMINER
	S ITEM="I-331.2  expr1 is intlit" S VCOMP=$P(0002304501,00,002,03),VCORR="4501" D EXAMINER
	S ITEM="I-331.3  intexpr3<-1" S VCOMP=$P("ABCBD","B",-3,2) S VCORR="ABC" D EXAMINER
	S ITEM="I-331.4  intexpr4>$L(expr1)" S VCOMP=$P("ABCBD","B",2,100) S VCORR="CBD" D EXAMINER
	S ITEM="I-331.5  $F(expr1,expr2)=0" S VCOMP=$P("ABCDE",3,4,5) S VCORR="" D EXAMINER
	S ITEM="I-331.6  expr1 contains _ binary operator" S VCOMP=$P("AB"_2_"BD","B",2,2) S VCORR=2 D EXAMINER
	S ITEM="I-331.7  expr1 is empty string" S VCOMP=$P("","B",2,5) S VCORR="" D EXAMINER
	S ITEM="I-331.8  expr2 is empty string" S VCOMP=$P("ABCBD","",2,5) S VCORR="" D EXAMINER
	S ITEM="I-331.9  expr1 and expr2 are empty string",VCOMP=$P("","",2,5),VCORR="" D EXAMINER
	;
332	W !,"I-332  intexpr4 is non-integer"
	S ITEM="I-332.1  2.5" S VCOMP=$P(10.05,0.0,1.99999,2.5) S VCORR="10." D EXAMINER
	S ITEM="I-332.2  02.4560000",VCOMP=$P(12.324E2,2.00,1.0,02.4560000),VCORR="123" D EXAMINER
	;
333	W !,"I-333  intexpr3>intexpr4"
	S ITEM="I-333  " S VCOMP=$P("ABCBD","B",3,2) S VCORR="" D EXAMINER
	;
334	W !,"I-334  intexpr4>255"
	S ITEM="I-334  " S VCOMP=$P("A B C D E F G "," ",3,9876545) S VCORR="C D E F G " D EXAMINER
	;
END	W !!,"END OF V1FNP2",!
	S ROUTINE="V1FNP2",TESTS=21,AUTO=21,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
