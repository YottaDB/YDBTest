V1NR2	;NAKED REFERENCE -2-;YS-TS,V1NR,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1NR2: TEST OF NAKED REFERENCES ON GLOBAL VARIABLES -2-",!
651	W !,"I-651  effect of KILLing global variables on naked indicator"
	S ITEM="I-651.1  killing defined global variable",VCOMP=""
	K ^V1A S ^V1A(1,1)=6 K ^V1A(1) S ^(3)="F" S VCOMP=VCOMP_^V1A(3)
	K ^V1A S ^V1A(1,1)=4 K ^(1) S ^(3)="D" S VCOMP=VCOMP_^V1A(1,3)
	S VCORR="FD" D EXAMINER
	;
	S ITEM="I-651.2  killing undefined global variable",VCOMP=""
	K ^V1A S ^V1A(1,1)=7 K ^V1A(0) S ^(3)="G" S VCOMP=VCOMP_^V1A(3)
	K ^V1A S ^V1A(1,1)=5 K ^(0) S ^(3)="E" S VCOMP=VCOMP_^V1A(1,3)
	S VCORR="GE" D EXAMINER
	;
	S ITEM="I-651.3  2 globals using"
	K ^V1A,^V1B S ^V1A(1,1)=8,^V1B(1,3)="*" K ^V1A(1,2) S ^(3)="H"
	S VCOMP=^V1B(1,3)_^V1A(1,3)
	S VCORR="*H" D EXAMINER
	;
652	W !,"I-652  interpretation of naked reference"
	S ITEM="I-652  " K ^V1A
	S ^V1A(1,1)=11,^V1A(1,2,3)=123,^V1A(1,2,2)=122,^V1A(1,2,3,2)=1232
	S ^V1A(1,2,3,122,1232)="GLOBAL"
	S VCOMP=$DATA(^V1A(1,1)) S ^(^(1),^(2,3))=^(^(2),^(3,2))
	S VCOMP=VCOMP_^V1A(1,2,3,122,11,123),VCORR="1GLOBAL" D EXAMINER
	;
825	W !,"I-825  Naked reference of undefined global node whose immediate ascendant exist"
	S ITEM="I-825  " K ^V1C
	S ^V1C(2,2)=2200
	S VCOMP=$D(^V1C(2,2))_" "_$D(^(2,2))_" "_$DATA(^(2,2,2))_" "
	S ^(2)="22222" S VCOMP=VCOMP_$D(^(2))_" "_^V1C(2,2,2,2,2)_" "_$D(^V1C)
	S VCORR="1 0 0 1 22222 10" D EXAMINER
	;
826	W !,"I-826  Naked reference of undefined global node whose immediate ascendant does not exist"
	S ITEM="I-826.1  immediate ascendant is unsubscripted variable" K ^V1A,^V1A(1)
	S ^(1)=1000 S VCOMP=$D(^V1A)_" "_$D(^V1A(1))_" "_^V1A(1)_" "_$D(^V1A(1,2))
	S VCORR="10 1 1000 0" D EXAMINER
	;
	S ITEM="I-826.2  immediate ascendant is 2-subscripts variable" K ^V1A,^V1A(1)
	S VCOMP=$D(^V1A(1,2)) S ^(2,3)=123 S VCOMP=VCOMP_^V1A(1,2,3),VCORR="0123" D EXAMINER
	;
	S ITEM="I-826.3  another same level variable exist",VCOMP=""
	K ^V1A,^V1A(1,1) S ^V1A(1,1)="X",VCOMP=VCOMP_$D(^(1,3)),^(4)="3",VCOMP=VCOMP_^V1A(1,1,4)
	K ^V1A S ^V1A(1,1)=99,VCOMP=VCOMP_$D(^(1,3)) S ^(4)="4" S VCOMP=VCOMP_^V1A(1,1,4)
	S VCORR="0304" D EXAMINER
	;
END	W !!,"END OF V1NR2",!
	S ROUTINE="V1NR2",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K ^V1A,^V1B,^V1C K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
