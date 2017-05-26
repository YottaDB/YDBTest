V1FNP1	;FUNCTION $PIECE -1-;YS-TS,V1FN,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1FNP1: TEST OF $PIECE FUNCTION -1-",! W:$Y>55 #
	W !,"$PIECE(expr1,expr2,intexpr3)",! W:$Y>55 #
315	W !,"I-315  substring specified by intexpr3 exist intexpr1"
	S ITEM="I-315.1  intexpr3=1" S VCOMP=$PIECE("ABCBD","B",1) S VCORR="A" D EXAMINER
	S ITEM="I-315.2  intexpr3=2" S VCOMP=$P("ABCBD","B",2) S VCORR="C" D EXAMINER
	S ITEM="I-315.3  intexpr3=3" S VCOMP=$P("ABCBD","B",3) S VCORR="D" D EXAMINER
	S ITEM="I-315.4  intexpr3=4" S VCOMP=$P("ABCBD","B",4) S VCORR="" D EXAMINER
	S ITEM="I-315.5  expr1 contains unary operator" S VCOMP=$P(+"-1.5E",".",2) S VCORR="5" D EXAMINER
	;
316	W !,"I-316  substring specified by intexpr3 does not exist intexpr1"
	S ITEM="I-316.1  intexpr3=1" S VCOMP=$P("ABCBD","F",1) S VCORR="ABCBD" D EXAMINER
	S ITEM="I-316.2  intexpr3>$L(expr1)" S VCOMP=$P("ABCBD","bc",8) S VCORR="" D EXAMINER
	;
317	W !,"I-317  intexpr3<0"
	S ITEM="I-317  " S VCOMP=$P("ABCBD","B",-4) S VCORR="" D EXAMINER
	;
318	W !,"I-318  intexpr3=0"
	S ITEM="I-318  " S VCOMP=$P("ABCBD","B",0) S VCORR="" D EXAMINER
	;
319	W !,"I-319  intexpr3>$LENGTH(expr1)"
	S ITEM="I-319  " S VCOMP=$P("A""B""C""D""E","""",10) S VCORR="" D EXAMINER
	;
320	W !,"I-320  $LENGTH(expr1)<$LENGTH(expr2)"
	S ITEM="I-320.1  intexpr3=1" S VCOMP=$P("@@@@","@@@@@",1) S VCORR="@@@@" D EXAMINER
	S ITEM="I-320.2  intexpr3=2" S VCOMP=$P("@@@@","@@@@@",2) S VCORR="" D EXAMINER
	;
321	W !,"I-321  expr1=expr2"
	S ITEM="I-321  " S VCOMP=$P("789","789",1) S VCORR="" D EXAMINER
	;
322	W !,"I-322  intexpr3>255"
	S ITEM="I-322  " S VCOMP=$P(1111,1,99999999) S VCORR="" D EXAMINER
	;
323	W !,"I-323  intexpr3 is non-intexpr numeric"
	S ITEM="I-323.1  3.9999" S VCOMP=$P(112131419,"1",3.9999) S VCORR="2" D EXAMINER
	S ITEM="I-323.2  3.49999" S VCOMP=$P(0112118114,11,3.49999) S VCORR="8" D EXAMINER
	;
324	W !,"I-324  Control characters are used as delimiters (expr2)"
	S ITEM="I-324  " S X="A"_$C(9)_"B"_$C(9)_"C",Y=$C(9) S VCOMP=$P(X,Y,2) S VCORR="B" D EXAMINER
	;
END	W !!,"END OF V1FNP1",!
	S ROUTINE="V1FNP1",TESTS=17,AUTO=17,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
