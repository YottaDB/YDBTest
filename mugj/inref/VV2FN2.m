VV2FN2	;FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2FN2: TEST OF FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -2-",!
	W !!,"$LENGTH(expr1,expr2)",!
79	W !,"II-79  expr1 and expr2 are string literals"
	S ITEM="II-79  ",VCOMP="",VCOMP=$length("ABCBC","B")_$l("ABCBCABC","BC"),VCORR=34 D EXAMINER
	;
80	W !,"II-80  expr2 is empty string"
	S ITEM="II-80  ",VCOMP="",VCOMP=$L("ABC","") S VCORR="0" D EXAMINER
	;
81	W !,"II-81  $L(expr1)<$L(expr2)"
	S ITEM="II-81  ",VCOMP="" S VCOMP=$L("A","ABC") S VCORR="1" D EXAMINER
	;
82	W !,"II-82  $L(expr1,expr2)=3"
	S ITEM="II-82  ",VCOMP=$L("AAAA","AA")_$l("0000000000","00000"),VCORR="33" D EXAMINER
	;
83	W !,"II-83  $L(expr1,expr2)=2"
	S ITEM="II-83  ",VCOMP=$L("AAAA","AAA")_$L("0000000000","00000000"),VCORR=22 D EXAMINER
	;
84	W !,"II-84  expr1 and expr2 are empty strings"
	S ITEM="II-84  ",VCOMP="",VCOMP=$L("",""),VCORR="0" D EXAMINER
	;
85	W !,"II-85  expr1 is empty string"
	S ITEM="II-85  ",VCOMP="" S VCOMP=$L("","A") S VCORR="1" D EXAMINER
	;
86	W !,"II-86  $L(expr1,expr2)=1"
	S ITEM="II-86  ",VCOMP="" S VCOMP=$L("ABC","D") S VCORR="1" D EXAMINER
	;
87	W !,"II-87  expr1 and expr2 are variables"
	S ITEM="II-87  ",VCOMP="",X="ABC",Y="EGF" S VCOMP=$l(X,Y),VCORR=1 D EXAMINER
	;
88	W !,"II-88  $L(expr1,expr2)=256"
	S ITEM="II-88  ",VCOMP="" S X="" F I=1:1:255 S X=X_"A"
	S VCOMP=$L($E(X,1,254),"A")_$L(X,"A") S VCORR="255256" D EXAMINER
	;
89	W !,"II-89  expr2 is control character"
	S ITEM="II-89  ",VCOMP="" S A="" F I=1:1:99 S A=A_$C(9)
	S VCOMP=$L(A,$C(9)),VCORR=100 D EXAMINER
	;
90	W !,"II-90  expr1 is numeric literal"
	S ITEM="II-90  ",VCOMP=""
	S VCOMP=$L(001020304,0)_$L(13.5383,3)_$L(000.135383E2,3)_$L(-000.135373,3)
	S VCOMP=VCOMP_$l(123456,123)_$l(123.456,3.4)_$l(1-0.0000001,10-1)_$l("000000",00000)
	S VCORR="44442287" D EXAMINER
	;
	W !!,"$TEXT(+intexpr)  $TEXT(lineref)",!
95	W !,"II-95  $TEXT"
	S ITEM="II-95.1  intexpr=0",VCOMP="",VCOMP=$t(+0)_"*"_$TEXT(+00.987)
	S VCORR="VV2FN2*VV2FN2" D EXAMINER
	;
	S ITEM="II-95.2  ls is multi spaces",VCOMP=""
	S VCOMP=$t(T95)_"*"_$TEXT(T95+1)
	S VCORR="T95 ;$TEXT* ;$TEXT+1" D EXAMINER
	;
T95	;$TEXT
	;$TEXT+1
	;
END	W !!,"END OF VV2FN2",!
	S ROUTINE="VV2FN2",TESTS=14,AUTO=14,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
