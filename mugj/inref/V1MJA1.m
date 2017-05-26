V1MJA1	;LOCK,CLOSE,OPEN,$JOB,$TEST -1-;KO-TS,V1MJA,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	;
LOCK	W !!,"TEST OF LOCK AND $TEST",!
	K ^V1A,^V1B,^V1F
628	W !,"I-628  LOCK the same name in two partitions"
	S ITEM="I-628  ",VCOMP=""
	LOCK ^V1A(1,2) K ^V1F
	S POS="628" D HANG S VCOMP=VCOMP_^V1F
	S VCORR="0/0/0/1/1/1" D EXAMINER
	;
629	W !,"I-629  update or refer the variable which is LOCKed in another partition"
	S ITEM="I-629  ",VCOMP=""
	S ^V1A(1,2)=12,^V1A(23)=23000
	L ^V1A K ^V1F
	S POS="629" D HANG S VCOMP=VCOMP_^V1F_" "_^V1A(1,2)_" "_^V1A(23)_" "_^V1A(100)
	S VCORR="12/23000 23012 23000/10 10000" D EXAMINER L
	;
630	W !,"I-630  LOCK with timeout and its effect on $TEST"
	S ITEM="I-630  ",VCOMP=""
	L (^V1A,^V1B(1)):1 S VCOMP=VCOMP_$T_" " K ^V1F
	S POS="630" D HANG S VCOMP=VCOMP_^V1F
	S VCORR="1 0/0/1" D EXAMINER L
	;
631	W !,"I-631  postconditional of LOCK command"
	S ITEM="I-631  ",VCOMP=""
	L:1=0.1 ^V1A(2,2) K ^V1F
	S POS="631-1" D HANG S VCOMP=VCOMP_^V1F
	L ^V1A(2):1 S VCOMP=VCOMP_$T K ^V1F
	S POS="631-2" D HANG S VCORR="1/0" D EXAMINER
	;
632	W !,"I-632  LOCK more than one name at the same time"
	S ITEM="I-632  ",VCOMP=""
	K ^V1A L (^V1A,^V1A,^V1B(2,2,1)) K ^V1F
	S POS="632" D HANG S VCOMP=VCOMP_^V1F L
	S VCORR="0/0/" D EXAMINER
	;
633	W !,"I-633  effect of unLOCK on another partition"
	S ITEM="I-633  ",VCOMP=""
	L ^V1A(1) K ^V1F
	S POS="633-1" D HANG S VCOMP=VCOMP_^V1F
	L ^V1B:1 S VCOMP=VCOMP_$T_" " K ^V1F
	S POS="633-2" D HANG L ^V1B:1 S VCOMP=VCOMP_$T L
	S VCORR="0/1/0 1" D EXAMINER
	;
634	W !,"I-634  argument list of LOCK"
	S ITEM="I-634  ",VCOMP=""
	L ^V1A,^V1B K ^V1F
	S POS="634" D HANG S VCOMP=VCOMP_^V1F
	S VCORR="1/0" D EXAMINER
	;
635	W !,"I-635  indirection of LOCK argument"
	S ITEM="I-635  ",VCOMP=""
	S A="^V1A" L @A K ^V1F
	S POS="635" D HANG S VCOMP=VCOMP_^V1F
	S VCORR=0 D EXAMINER
	;
636	W !,"I-636  effect of LOCK on naked indicator"
	S ITEM="I-636  ",VCOMP=""
	S ^V1A(1)=1,^V1A(2)="^V1A(2)",^V1B(2)="^V1B(2)" L ^V1B(^V1A(1))
	S ^(2)=10 S VCOMP=VCOMP_^V1A(2) L
	S VCORR="10" D EXAMINER
	;
637	W !,"I-637  effect of LOCK on local variable reference"
	S ITEM="I-637  ",VCOMP=""
	S A(1,1)=99 L A(1,1) K ^V1F
	S POS="637" D HANG S VCOMP=VCOMP_A(1,1)_" "_^V1F
	S VCORR="99 0/0/1/0" D EXAMINER
	;
638	W !,"I-638  LOCK of non-variable name"
	S ITEM="I-638  "
	W !,"   DELETE  ",ITEM W:$Y>55 # Q
	;
END	W !!,"END OF V1MJA1",!
	S ROUTINE="V1MJA1",TESTS=10,AUTO=10,VISUAL=0 D ^VREPORT
	K ^V1A,^V1B,^V1F K  L  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
HANG	F I=1:1 Q:$D(^V1F)  H 1
	Q
