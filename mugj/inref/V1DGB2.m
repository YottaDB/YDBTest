V1DGB2	;$DATA, KILL (GLOBAL VARIABLES) -3-;YS-TS,V1DGB,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1DGB2 : TEST OF $DATA FUNCTION AND KILL COMMAND ON GLOBAL VARIABLES -3-",!
206	W !,"I-206  $DATA of defined node which has descendants 2 levels below"
	S ITEM="I-206  ",VCOMP="" K ^V1 S ^V1=000
	S ^V1(1)=1,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=3 D DATA
	K ^V1(2) D DATA
	S VCORR="11 1 11 11 1 1 1 *0*1*2*21*211*22*3*/11 1 0 0 0 0 1 *0*1*****3*/" D EXAMINER
	;
207	W !,"I-207  $DATA of defined node whose immediate descendants are killed"
	S ITEM="I-207  ",VCOMP="" K ^V1
	S ^V1(1)=1,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=300 D DATA
	K ^V1(2) D DATA
	S VCORR="10 1 11 11 1 1 1 **1*2*21*211*22*300*/10 1 0 0 0 0 1 **1*****300*/" D EXAMINER
	;
208	W !,"I-208  $DATA of defined node whose descendants 2 levels below are killed"
	S ITEM="I-208  ",VCOMP="" K ^V1
	S ^V1(1)=1,^V1(2)=2,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=3000 D DATA
	K ^V1(2,1,1) D DATA
	S VCORR="10 1 11 10 1 1 1 **1*2**211*22*3000*/10 1 11 0 0 1 1 **1*2***22*3000*/" D EXAMINER
	;
209	W !,"I-209  $DATA of defined node whose parent is killed"
	S ITEM="I-209  ",VCOMP=""
	S ^V1=0,^V1(1)="1 HAPPY",^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211.1,^V1(3)=3
	K ^V1 D DATA
	S VCORR="0 0 0 0 0 0 0 ********/" D EXAMINER
	;
210	W !,"I-210  $DATA of defined node whose neighboring node is killed"
	S ITEM="I-210  ",VCOMP="" K ^V1
	S ^V1="ROOT",^V1(2,1,1)=2110,^V1(3)=3000 D DATA
	K ^V1A(1,2,3,4),^V1ZZZ(9,9,9) K A,B,C,V1,^V10,^V11,^V1(0)
	K ^V1(2,1,1) D DATA K ^V1(3) D DATA
	S VCORR="11 0 10 10 1 0 1 *ROOT****2110**3000*/11 0 0 0 0 0 1 *ROOT******3000*/1 0 0 0 0 0 0 *ROOT*******/" D EXAMINER
	;
END	W !!,"END OF V1DGB2",!
	S ROUTINE="V1DGB2",TESTS=5,AUTO=5,VISUAL=0 D ^VREPORT
	K  K ^V1,^V1A,^V1ZZZ,^V10,^V11 Q
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
