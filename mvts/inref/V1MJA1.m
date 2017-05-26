V1MJA1 ;IW-KO-TS,V1MJA,MVTS V9.10;15/6/96;LOCK, OPEN, CLOSE, $JOB, $IO and $TEST  -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 S ^V1C(1,1)=$IO,^V1C(1,2)=$I,^NEXT="END^VV1"
 ;
 W !!,"195---V1MJA1: Multi-job  -1-"
 W !!,"Tests of LOCK and $TEST",!
 K ^V1A,^V1B,^V1F
628 W !,"I-628  LOCK the same name in two partitions"
 S ^ABSN="12131",^ITEM="I-628  LOCK the same name in two partitions",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 LOCK ^V1A(1,2) K ^V1F
 S POS="628" D HANG S VCOMP=VCOMP_^V1F
 S ^VCOMP=VCOMP,^VCORR="0/0/0/1/1/1" D ^VEXAMINE
 ;
629 W !,"I-629  Update or refer the variable which is LOCKed in another partition"
 S ^ABSN="12132",^ITEM="I-629  Update or refer the variable which is LOCKed in another partition",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 S ^V1A(1,2)=12,^V1A(23)=23000
 L ^V1A K ^V1F
 S POS="629" D HANG S VCOMP=VCOMP_^V1F_" "_^V1A(1,2)_" "_^V1A(23)_" "_^V1A(100)
 S ^VCOMP=VCOMP,^VCORR="12/23000 23012 23000/10 10000" D ^VEXAMINE L
 ;
630 W !,"I-630  LOCK with timeout and its effect on $TEST"
 S ^ABSN="12133",^ITEM="I-630  LOCK with timeout and its effect on $TEST",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 L (^V1A,^V1B(1)):1 S VCOMP=VCOMP_$T_" " K ^V1F
 S POS="630" D HANG S VCOMP=VCOMP_^V1F
 S ^VCOMP=VCOMP,^VCORR="1 0/0/1" D ^VEXAMINE L
 ;
631 W !,"I-631  Postconditional of LOCK command"
 S ^ABSN="12134",^ITEM="I-631  Postconditional of LOCK command",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 L:1=0.1 ^V1A(2,2) K ^V1F
 S POS="631-1" D HANG S VCOMP=VCOMP_^V1F
 L ^V1A(2):1 S VCOMP=VCOMP_$T K ^V1F
 S POS="631-2" D HANG S ^VCOMP=VCOMP,^VCORR="1/0" D ^VEXAMINE
 ;
632 W !,"I-632  LOCK more than one name at the same time"
 S ^ABSN="12135",^ITEM="I-632  LOCK more than one name at the same time",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 K ^V1A L (^V1A,^V1A,^V1B(2,2,1)) K ^V1F
 S POS="632" D HANG S VCOMP=VCOMP_^V1F L
 S ^VCOMP=VCOMP,^VCORR="0/0/" D ^VEXAMINE
 ;
633 W !,"I-633  Effect of unLOCK on another partition"
 S ^ABSN="12136",^ITEM="I-633  Effect of unLOCK on another partition",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 L ^V1A(1) K ^V1F
 S POS="633-1" D HANG S VCOMP=VCOMP_^V1F
 L ^V1B:1 S VCOMP=VCOMP_$T_" " K ^V1F
 S POS="633-2" D HANG L ^V1B:1 S VCOMP=VCOMP_$T L
 S ^VCOMP=VCOMP,^VCORR="0/1/0 1" D ^VEXAMINE
 ;
634 W !,"I-634  Argument list of LOCK"
 S ^ABSN="12137",^ITEM="I-634  Argument list of LOCK",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 L ^V1A,^V1B K ^V1F
 S POS="634" D HANG S VCOMP=VCOMP_^V1F
 S ^VCOMP=VCOMP,^VCORR="1/0" D ^VEXAMINE
 ;
635 W !,"I-635  Indirection of LOCK argument"
 S ^ABSN="12138",^ITEM="I-635  Indirection of LOCK argument",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 S A="^V1A" L @A K ^V1F
 S POS="635" D HANG S VCOMP=VCOMP_^V1F
 S ^VCOMP=VCOMP,^VCORR=0 D ^VEXAMINE
 ;
636 W !,"I-636  Effect of LOCK on naked indicator"
 S ^ABSN="12139",^ITEM="I-636  Effect of LOCK on naked indicator",^NEXT="END^VV1" D ^V1PRESET
 S VCOMP=""
 S ^V1A(1)=1,^V1A(2)="^V1A(2)",^V1B(2)="^V1B(2)" L ^V1B(^V1A(1))
 S ^(2)=10 S VCOMP=VCOMP_^V1A(2) L
 S ^VCOMP=VCOMP,^VCORR="10" D ^VEXAMINE
 ;
637 W !,"I-637  Effect of LOCK on local variable reference"
 S ^ABSN="12140",^ITEM="I-637  Effect of LOCK on local variable reference",^NEXT="638^V1MJA1,END^VV1" D ^V1PRESET
 S VCOMP=""
 S A(1,1)=99 L A(1,1) K ^V1F
 S POS="637" D HANG S VCOMP=VCOMP_A(1,1)_" "_^V1F
 S ^VCOMP=VCOMP,^VCORR="99 0/0/1/0" D ^VEXAMINE
 ;
638 W !,"I-638  LOCK of non-variable name"
 W !,"   I-638  (Test I-638 was withdrawn for its implementation dependency before X11.1-'77. Jun 15, 1978, MSL)"
 S ^ABSN="12141",^ITEM="I-638  LOCK of non-variable name",^NEXT="END^VV1" D ^V1PRESET
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 195---V1MJA1",!
 K ^V1A,^V1B,^V1F K  L  Q
 ;
HANG F I=1:1 Q:$D(^V1F)  H 1
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
