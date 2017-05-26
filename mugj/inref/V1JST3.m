V1JST3	; $JUSTIFY, $SELECT, $TEXT -3-;YS-KO-TS,V1JST,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1JST3: TEST OF $JUSTIFY, $SELECT AND $TEXT FUNCTIONS -3-",!
SELECT	W !,"$SELECT(L tvexpr:expr)",!
586	W !,"I-586  single argument"
	S ITEM="I-586  " S VCOMP=$SELECT("ABC"="ABC":"...PASSED") S VCORR="...PASSED" D EXAMINER
	;
587	W !,"I-587  effect on $TEST"
	S ITEM="I-587.1  $TEST=1",VCOMP="" I 1 S VCOMP=$S(0:0,$T:"...PASSED",1:"...FAILED"),VCOMP=VCOMP_$TEST
	I  S VCOMP=VCOMP_" IF "
	E  S VCOMP=VCOMP_" ELSE "
	S VCORR="...PASSED1 IF " D EXAMINER
	;
	S ITEM="I-587.2  $TEST=0",VCOMP="" I 0
	S VCOMP=$S(0:0,$T:"...PASSED",0:1,1:"...FAILED"),VCOMP=VCOMP_$TEST
	I  S VCOMP=VCOMP_" IF "
	E  S VCOMP=VCOMP_" ELSE "
	S VCORR="...FAILED0 ELSE " D EXAMINER
	;
588	W !,"I-588  interpretation sequence of $SELECT argument"
	S ITEM="I-588  ",VCOMP=""
	S VCOMP=$SELECT(1=2:"...""FA""""ILED",1<2:"...""PASSED")
	S VCORR="...""PASSED" D EXAMINER
	;
589	W !,"I-589  interpretation of tvexpr"
	S ITEM="I-589  ",VCOMP=""
	K ^V1A,^V1B S ^V1A(1)=0,^(4)="ABC",^(5,6)="...PASSED"
	S ^V1B(2,3)=9,^(4)="XYZ",^(5,6)="NG",^V1C(7)=1,^V1D(8,9)="FAILED"
	S VCOMP=$S(^V1A(1)=1:^V1B(2,3),^(4)["A":^(5,6),^V1C(7)=1:^V1D(8,9))
	S VCORR="...PASSED" DO EXAMINER
	;
590	W !,"I-590  interpretation of expr, while tvexpr=0"
	S ITEM="I-590  " K ^V1A
	S ^V1A(2,2)=22,^V1A(2,2,2)=222,^V1A(2,2,2,2)=2222
	S VCOMP=$D(^V1A(2))_" "_$S(^(2,2)>2000:^(2,2),^(2,2)>1:^(2,2))_" "_^(2)
	S VCORR="10 2222 2222" D EXAMINER
	;
591	W !,"I-591  interpretation of expr, while tvexpr=1"
	S ITEM="I-591  " K ^V1A
	S ^V1A(2,2)=22,^V1A(2,2,2)=222,^V1A(2,2,2,2)=2222
	S VCOMP=$D(^V1A(2))_" "_$S(^(2,2)>1:^(2,2),^(2,2):^(2,2))_" "_^(2)
	S VCORR="10 222 222" D EXAMINER
	;
592	W !,"I-592  nesting of functions"
	S ITEM="I-592  ",VCOMP="" K X S VCOMP=$S($D(X):X,1:",,:"_"PASSED")
	S VCORR=",,:PASSED" D EXAMINER
	;
TEXT	W !!,"$TEXT(lineref),  $TEXT(+intexpr)",!
593	W !,"I-593  the line specified by lineref does not exist"
	S ITEM="I-593  " S VCOMP=$TEXT(QQQQQQ),VCORR="" D EXAMINER
	;
594	W !,"I-594  the line specified by +intexpr does not exist"
	S ITEM="I-594  " S VCOMP=$T(+500),VCORR="" D EXAMINER
	;
595	W !,"I-595  the line specified by lineref exist"
	S ITEM="I-595.1  lineref is a label"
	S VCOMP=$TEXT(Z1),VCORR="Z1 ;THE $TEXT TEST 1" D EXAMINER
	;
	S ITEM="I-595.2  lineref is a another label" S VCOMP=$T(595)
	S VCORR="595 W !,""I-595  the line specified by lineref exist""" D EXAMINER
	;
	S ITEM="I-595.3  nesting of function" S VCOMP=$P($TEXT(TEXT),"  ",2)
	S VCORR="$TEXT(+intexpr)"",!" D EXAMINER
	;
596	W !,"I-596  the line specified by +intexpr exist"
	S ITEM="I-596  "
	S VCOMP=$T(+2.5),VCORR=" ;COPYRIGHT MUMPS SYSTEM LABORATORY 1978" D EXAMINER
	;
597	W !,"I-597  lineref=label"
	S ITEM="I-597  " S VCOMP=$T(Z4),VCORR="Z4 ;THE $TEXT ""TEST"" 4" D EXAMINER
	;
598	W !,"I-598  lineref=label+intexpr"
	S ITEM="I-598  " S VCOMP=$T(Z1+1),VCORR="Z2 ;" D EXAMINER
	;
599	W !,"I-599/600  indirection of argument"
	S ITEM="I-599/600  "
	S X="Z4",Y=0,Z="Y",VCOMP=$T(@X+@Z),VCORR="Z4 ;THE $TEXT ""TEST"" 4" D EXAMINER
	;
END	W !!,"END OF V1JST3",!
	S ROUTINE="V1JST3",TESTS=17,AUTO=17,VISUAL=0 D ^VREPORT
	K  K ^V1A,^V1B,^V1C,^V1D Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
Z1	;THE $TEXT TEST 1
Z2	;
Z4	;THE $TEXT "TEST" 4
