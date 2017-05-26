VV2FN1	;FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -1-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2FN1: TEST OF FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -1-",!
	W !,"$DATA(glvn)",!
69	W !,"II-69  Effect of local variable descendant KILL"
	S ITEM="II-69  ",VCOMP=""
	K VV S VV(1)=0,VV(1,2)=0 k VV(1,2) S VCOMP=$d(VV(1)) S VCORR=1 D EXAMINER
	;
70	W !,"II-70  Effect of global variable descendant KILL"
	S ITEM="II-70  ",VCOMP=""
	K ^VV S ^VV(1)=0,^(1,2)=0 K ^(2) S VCOMP=$D(^VV(1)) S VCORR="1" D EXAMINER
	;
	W !!,"$EXTRACT(expr)",!
71	W !,"II-71  expr is strlit"
	S ITEM="II-71  ",VCOMP="",VCOMP=$e("ABC"),VCORR="A" D EXAMINER
	;
72	W !,"II-72  expr is 255 characters"
	S ITEM="II-72  " S VCOMP="",X="B" F I=1:1:254 S X=X_"A"
	S VCOMP=$extract(X),VCORR="B" D EXAMINER
	;
73	W !,"II-73  expr is empty string"
	S ITEM="II-73  ",VCOMP="ERROR",VCOMP=$e(""),VCORR="" D EXAMINER
	;
74	W !,"II-74  expr is numeric literal"
	S ITEM="II-74  ",VCOMP=""
	S VCOMP=$E(-123.3E-2)_$E(000.34)_$E(0.23E5)_$e(00076.450)
	S VCORR="-.27" D EXAMINER
	;
	W !!,"$FIND(expr1,expr2,intexpr3)",!
75	W !,"II-75  intexpr3<0 and expr1 is strlit"
	S ITEM="II-75  ",VCOMP="",VCOMP=$f("ABC","A",-1),VCORR="2" D EXAMINER
	;
76	W !,"II-76  intexpr3<0 and expr1 is variable"
	S ITEM="II-76  ",VCOMP="",X="ABC8",Y="B",VCOMP=$Find(X,Y,123-557),VCORR=3 D EXAMINER
	;
	W !!,"$JUSTIFY(numexpr1,intexpr2,intexpr3)",!
77	W !,"II-77  0<numexpr1<1"
	S ITEM="II-77  ",VCOMP="",VCOMP=$justify(000.123,5,2)_$j(789E-3,4,1)
	S X=2,Y=3 S VCOMP=VCOMP_$J(X/Y,X,Y) S VCORR=" 0.12 0.80.667" D EXAMINER
	;
78	W !,"II-78  -1<numexpr1<0"
	S ITEM="II-78  ",VCOMP="" S VCOMP=$justify(-0.123,6,2)_$j(-1+.241,5,1)
	S VCORR=" -0.12 -0.8" D EXAMINER
	;
	W !!,"$PIECE(expr1,expr2)",!
91	W !,"II-91  expr1 and expr2 are strlits"
	S ITEM="II-91  ",VCOMP=""
	S VCOMP=$PIECE("ABC","B")_"*"_$Piece("ABC","D")_"*"_$p("ABC","BC")
	S VCORR="A*ABC*A" D EXAMINER
	;
92	W !,"II-92  expr2 is empty string"
	S ITEM="II-92  ",VCOMP="",VCOMP=$P("ABC",""),VCORR="" D EXAMINER
	;
93	W !,"II-93  expr1 is empty string"
	S ITEM="II-93  ",VCOMP="",VCOMP=$P("","AB"),VCORR="" D EXAMINER
	;
94	W !,"II-94  expr1 and expr2 are variables"
	S ITEM="II-94  ",VCOMP="",X="AAAA",Y="AAAAA",Z="AAA",VCOMP=$P(X,Y)_"*"_$P(X,Z)_"*"
	S X="C"_$C(7)_"B"_$C(7)_"A",VCOMP=VCOMP_$P(X,$C(7))_"*"
	S X=0000123456E-3,Y=".",X(1)=976.565,Y(1.0)=6.56,VCOMP=VCOMP_$P(X,Y)_"*"_$P(X(1),Y(1))
	S VCORR="AAAA**C*123*97" D EXAMINER
	;
END	W !!,"END OF VV2FN1",!
	S ROUTINE="VV2FN1",TESTS=14,AUTO=14,VISUAL=0 D ^VREPORT
	K  K ^VV Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
