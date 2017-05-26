V1DLB1	;$DATA, KILL (LOCAL VARIABLES) -2-;YS-TS,V1DLB,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S ^PASS=0,^FAIL=0
	W !!,"V1DLB1 : TEST OF $DATA FUNCTION AND KILL COMMAND ON LOCAL VARIABLES -2-",!
220	W !,"I-220  $DATA of undefined node which has immediate descendants"
	S ^ITEM="I-220  ",VCOMP="" K XX
	S XX(2,1)=210 D DATA K XX(2) D DATA
	S VCORR="10 0 10 1 0 0 0 ****210****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
221	W !,"I-221  $DATA of undefined node which has descendants 2 levels below"
	S ^ITEM="I-221  ",VCOMP="" K XX
	S XX(2,1,1)=2110 D DATA K XX(2) D DATA
	S VCORR="10 0 10 10 1 0 0 *****2110***/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
222	W !,"I-222  $DATA of undefined node whose immediate descendants are killed"
	S ^ITEM="I-222  ",VCOMP="" K XX
	S XX(2,1)="DEF" D DATA K XX(2,1) D DATA
	S VCORR="10 0 10 1 0 0 0 ****DEF****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
223	W !,"I-223  $DATA of undefined node whose descendants 2 levels below are killed"
	S ^ITEM="I-223  ",VCOMP="" K XX
	S XX(2,1,1)=2110 D DATA K XX(2,1,1) D DATA
	S VCORR="10 0 10 10 1 0 0 *****2110***/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
224	W !,"I-224  $DATA of defined node which has immediate descendants"
	S ^ITEM="I-224  ",VCOMP="" K XX
	S XX(2)=2000,XX(2,1)="210QWE" D DATA K XX(2) D DATA
	S VCORR="10 0 11 1 0 0 0 ***2000*210QWE****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
225	W !,"I-225  $DATA of defined node which has descendants 2 levels below"
	S ^ITEM="I-225  ",VCOMP="" K XX
	S XX(2)=200,XX(2,1,1)=21100 D DATA K XX(2) D DATA
	S VCORR="10 0 11 10 1 0 0 ***200**21100***/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
END	W !!,"END OF V1DLB1",!
	S PASS=^PASS,FAIL=^FAIL
	S ROUTINE="V1DLB1",TESTS=6,AUTO=6,VISUAL=0 D ^VREPORT
	K  K ^ITEM,^PASS,^FAIL Q
	;
EXAMINER	I VCORR=VCOMP S PASS=^PASS,PASS=PASS+1,^PASS=PASS W !,"   PASS  ",^ITEM W:$Y>55 # Q
	S FAIL=^FAIL,FAIL=FAIL+1,^FAIL=FAIL W !,"** FAIL  ",^ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
DATA	S VCOMP=VCOMP_$D(XX)_" "_$D(XX(1))_" "_$D(XX(2))_" "_$D(XX(2,1))_" "
	S VCOMP=VCOMP_$D(XX(2,1,1))_" "_$D(XX(2,2))_" "_$D(XX(3))_" "
	S VCOMP=VCOMP_"*" I $D(XX)#10=1 S VCOMP=VCOMP_XX
	S VCOMP=VCOMP_"*" I $D(XX(1))#10=1 S VCOMP=VCOMP_XX(1)
	S VCOMP=VCOMP_"*" I $D(XX(2))#10=1 S VCOMP=VCOMP_XX(2)
	S VCOMP=VCOMP_"*" I $D(XX(2,1))#10=1 S VCOMP=VCOMP_XX(2,1)
	S VCOMP=VCOMP_"*" I $D(XX(2,1,1))#10=1 S VCOMP=VCOMP_XX(2,1,1)
	S VCOMP=VCOMP_"*" I $D(XX(2,2))#10=1 S VCOMP=VCOMP_XX(2,2)
	S VCOMP=VCOMP_"*" I $D(XX(3))#10=1 S VCOMP=VCOMP_XX(3)
	S VCOMP=VCOMP_"*/" Q
