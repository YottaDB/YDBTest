V1DGB1	;$DATA, KILL (GLOBAL VARIABLES) -2-;YS-TS,V1DGB,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1DGB1 : TEST OF $DATA FUNCTION AND KILL COMMAND ON GLOBAL VARIABLES -2-",!
823	W !,"I-823  KILLing undefined subscripted global variables"
	S ITEM="I-823  ",VCOMP="" KILL ^V1 DO DATA K ^V1(2) D DATA
	S VCORR="0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
201	W !,"I-201  $DATA of undefined node which has immediate descendants"
	S ITEM="I-201  ",VCOMP="" K ^V1
	S ^V1(2,1)=200 D DATA K ^V1(2) D DATA
	S VCORR="10 0 10 1 0 0 0 ****200****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
202	W !,"I-202  $DATA of undefined node which has descendants 2 levels below"
	S ITEM="I-202  ",VCOMP="" K ^V1
	S ^V1(2,2)=220,^V1(3)=300,^V1(2,1,1)=211 D DATA K ^V1(2) D DATA
	S VCORR="10 0 10 10 1 1 1 *****211*220*300*/10 0 0 0 0 0 1 *******300*/" D EXAMINER
	;
203	W !,"I-203  $DATA of undefined node whose immediate descendants are killed"
	S ITEM="I-203  ",VCOMP="" K ^V1
	S ^V1(2,1)=200 D DATA K ^V1(2,1) D DATA
	S VCORR="10 0 10 1 0 0 0 ****200****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
204	W !,"I-204  $DATA of undefined node whose descendants 2 levels below are killed"
	S ITEM="I-204  ",VCOMP="" K ^V1
	S ^V1(3)=300,^V1(2,1,1)=211 D DATA K ^V1(2,1,1) D DATA
	S VCORR="10 0 10 10 1 0 1 *****211**300*/10 0 0 0 0 0 1 *******300*/" D EXAMINER
	;
205	W !,"I-205  $DATA of defined node which has immediate descendants"
	S ITEM="I-205  ",VCOMP="" K ^V1
	S ^V1(1)=100,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=300 D DATA
	K ^V1(2) D DATA
	S VCORR="10 1 11 11 1 1 1 **100*2*21*211*22*300*/10 1 0 0 0 0 1 **100*****300*/" D EXAMINER
	;
END	W !!,"END OF V1DGB1",!
	S ROUTINE="V1DGB1",TESTS=6,AUTO=6,VISUAL=0 D ^VREPORT
	K  K ^V1 Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
DATA	S VCOMP=VCOMP_$D(^V1)_" "_$D(^V1(1))_" "_$D(^V1(2))_" "_$D(^V1(2,1))_" "
	S VCOMP=VCOMP_$D(^V1(2,1,1))_" "_$D(^V1(2,2))_" "_$D(^V1(3))_" "
	S VCOMP=VCOMP_"*" I $D(^V1)#10=1 S VCOMP=VCOMP_^V1
	S VCOMP=VCOMP_"*" I $D(^V1(1))#10=1 S VCOMP=VCOMP_^V1(1)
	S VCOMP=VCOMP_"*" I $D(^V1(2))#10=1 S VCOMP=VCOMP_^V1(2)
	S VCOMP=VCOMP_"*" I $D(^V1(2,1))#10=1 S VCOMP=VCOMP_^V1(2,1)
	S VCOMP=VCOMP_"*" I $D(^V1(2,1,1))#10=1 S VCOMP=VCOMP_^V1(2,1,1)
	S VCOMP=VCOMP_"*" I $D(^V1(2,2))#10=1 S VCOMP=VCOMP_^V1(2,2)
	S VCOMP=VCOMP_"*" I $D(^V1(3))#10=1 S VCOMP=VCOMP_^V1(3)
	S VCOMP=VCOMP_"*/" Q
