VV2NO	;$NEXT AND $ORDER;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2NO: TEST OF $NEXT AND $ORDER",!
	W !," Though the use of ""negative numeric subscripts"" is restricted in"
	W !,"Portability Requirements 2.2.3, they are ""arbitrarily"" tested in $NEXT"
	W !,"(function under way of being switched to $ORDER)."
	W !,"Such failures SHOULD NOT be counted as FAILURES."
	KILL A,^VV,V1,^V1,X
	S A(-999999999)="",A(-10)="",A(-1.2)="",A(-1.11)="",A("-1.1")=""
	S A("-1")="",A(-.5)="",A(0)="",A(+0.5)="",A("1.1")="",A(999999999)=""
	S A("#")="",A("%")="",A("+4")="",A("-4.")="",A("-4.0")="",A(".0")=""
	S A(".00")="",A("0.0")="",A("0.1")="",A("1.")="",A("1.0")="",A("A")=""
	S A("AA")="",A("AB")=""
	S A("00")="",A("01")="",A("20")="",A("123E1")="",A("--1")="",A("-0")=""
	S A("1.1.2")="",A("-")="",A("-.")="",A("-.0")="",A(".")=""
	S ^VV(-999999999)="",^VV(-10)="",^VV(-1.2)="",^VV(-1.11)="",^VV("-1.1")=""
	S ^VV("-1")="",^VV(-.5)="",^VV(0)="",^VV(+0.5)="",^VV("1.1")=""
	S ^VV(999999999)="",^VV("#")="",^VV("%")="",^VV("+4")="",^VV("-4.")=""
	S ^VV("-4.0")="",^VV(".0")="",^VV(".00")="",^VV("0.0")="",^VV("0.1")=""
	S ^VV("1.")="",^VV("1.0")="",^VV("A")="",^VV("AA")="",^VV("AB")=""
	S ^VV("00")="",^VV("01")="",^VV("20")="",^VV("123E1")="",^VV("--1")=""
	S ^VV("-0")=""
	S ^VV("1.1.2")="",^VV("-")="",^VV("-.")="",^VV("-.0")="",^VV(".")=""
	;
	S X(1)="-999999999 -10 -1.2 -1.11 -1.1 -1 "
	S X(2)="-.5 0 .5 1.1 20 999999999 # % +4 - --1 -. -.0 -0 -4. "
	S X(3)="-4.0 . .0 .00 0.0 0.1 00 01 1. 1.0 1.1.2 123E1 A AA AB "
	S X(4)="0123456789 !""#$%&'()*+,-./" F I=58:1:126 S X(4)=X(4)_$C(I)
	;
	W !!,"$NEXT(glvn)",!
167	W !,"II-167  Sequence from -1 when glvn is lvn"
	S ITEM="II-167.1  subscript is a string",VCOMP="",X=-1
	F I=1:1:12 S X=$N(A(X)) S VCOMP=VCOMP_X_" "
	S X=-.9999 F I=1:1:15 S X=$N(A(X)) S VCOMP=VCOMP_X_" "
	F I=1:1 S X=$N(A(X)) Q:X=-1  S VCOMP=VCOMP_X_" "
	S VCORR=X(1)_X(1)_X(2)_X(3) D EXAMINER
	;
	S ITEM="II-167.2  subscript is one character (all graphic characters)",VCOMP=""
	K V1 F I=126:-1:32 S V1($C(I))=""
	S X=-1 F I=0:0 S X=$N(V1(X)) Q:X=-1  S VCOMP=VCOMP_X
	S VCORR=X(4) D EXAMINER
	;
168	W !,"II-168  Sequence from -1 when glvn is gvn"
	S ITEM="II-168.1  subscript is a string",VCOMP="",X=-1
	F I=1:1:12 S X=$N(^VV(X)) s VCOMP=VCOMP_X_" "
	S X=-0.99989 F I=1:1:15 S X=$N(^VV(X)) s VCOMP=VCOMP_X_" "
	F I=1:1 S X=$n(^VV(X)) Q:X=-1  set VCOMP=VCOMP_X_" "
	S VCORR=X(1)_X(1)_X(2)_X(3) D EXAMINER
	;
	S ITEM="II-168.2  subscript is one character (all graphic characters)",VCOMP=""
	K ^V1 F I=32:1:126 S ^V1(1,2,3,"ABC","A","B",$C(I))=""
	S X=-1 F I=0:0 S X=$next(^(X)) Q:X=-1  S VCOMP=VCOMP_X
	S VCORR=X(4) D EXAMINER
	;
	W !!,"$ORDER(glvn)",!
169	W !,"II-169  Sequence from empty string when glvn is lvn"
	S ITEM="II-169.1  subscript is a string",VCOMP="",X=""
	for I=1:1:6 S X=$O(A(X)) S VCOMP=VCOMP_X_" "
	F I=1:1:15 S X=$o(A(X)) S VCOMP=VCOMP_X_" "
	F I=1:1 S X=$order(A(X)) Q:X=""  S VCOMP=VCOMP_X_" "
	S VCORR=X(1)_X(2)_X(3) D EXAMINER
	;
	S ITEM="II-169.2  subscript is one character (all graphic characters)",VCOMP="",X=""
	K V1 F I=126:-1:32 S V1($C(I))=""
	S X="" F I=0:0 S X=$O(V1(X)) Q:X=""  S VCOMP=VCOMP_X
	S VCORR=X(4) D EXAMINER
	;
170	W !,"II-170  Sequence from empty string when glvn is gvn"
	S ITEM="II-170.1  subscript is a string",VCOMP="",X=""
	f I=1:1:6 S X=$O(^VV(X)) S VCOMP=VCOMP_X_" "
	F I=1:1:15 S X=$o(^VV(X)) S VCOMP=VCOMP_X_" "
	F I=1:1 S X=$order(^VV(X)) quit:X=""  S VCOMP=VCOMP_X_" "
	S VCORR=X(1)_X(2)_X(3) D EXAMINER
	;
	S ITEM="II-170.2  subscript is one character (all graphic characters)",VCOMP="",X=""
	K ^V1 F I=32:1:126 S ^V1(1,2,3,"ABC","A","B",$C(I))=""
	S X="" F I=0:0 S X=$O(^(X)) q:X=""  S VCOMP=VCOMP_X
	S VCORR=X(4) D EXAMINER
	;
END	W !!,"END OF VV2NO",!
	S ROUTINE="VV2NO",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  K ^VV,^V1 Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
