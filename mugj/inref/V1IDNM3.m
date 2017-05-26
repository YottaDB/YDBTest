V1IDNM3	;NAME LEVEL INDIRECTION -3-;KO-TS,V1IDNM,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDNM3: TEST OF NAME LEVEL INDIRECTION -3-"
DATA	W !!,"$DATA(@expratom)",! KILL (PASS,FAIL)
509	W !,"I-509  indirection of $DATA argument"
	S ITEM="I-509  "
	K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)=3,^V1A(1,1)=11,^V1A(2,2)=22,^(2,2)=222
	S ^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
	S A="^V1A",B="^V1A(0)",C="^(1)",D="^(1,1)"
	S VCOMP=$D(@A)_" "_$D(@B)_" "_$D(@C)_" "_$D(@D),VCORR="10 1 11 1" D EXAMINER
	;
510	W !,"I-510  indirection of subscript"
	S ITEM="I-510  ",VCOMP=""
	K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)=3,^V1A(1,1)=11
	S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
	S A="@B",B="^V1A(@G)",G="Y",Y=3,C="D",D=3
	S VCOMP=VCOMP_$D(^V1A(3,@C,@G,30/10))_" "_$D(^V1A(@A,3,@G))
	S VCORR="10 11" D EXAMINER
	;
511	W !,"I-511  2 levels of indirection"
	S ITEM="I-511  ",VCOMP=""
	K ^V1A S ^V1A(0)=0,^(1)=1,^(2)=2,^(3)="^V1A",^V1A(1,1)=11
	S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
	S A="@B",B="@^V1A(@Y)",G="Y",Y="Z",Z=3,H="^V1A(@@G,3,@@G)"
	S VCOMP=VCOMP_$D(@H)_" "_$DATA(@A),VCORR="11 10" D EXAMINER
	;
512	W !,"I-512  3 levels of indirection"
	S ITEM="I-512  ",VCOMP=""
	K ^V1A S ^V1A(0)=0,^(1)="^V1A(2,2,2)",^(2)=2,^(3)="@^V1A(1)",^V1A(1,1)=11
	S ^V1A(2,2)=22,^(2,2)=222,^V1A(3,3)=33,^(3,3)=333,^(3,3,3)=33333
	S A="@B",B="@^V1A(@@Y)",G="Y",Y="Z",Z="Q",Q=3,H="^V1A(@@@G,3,@@@G)"
	S VCOMP=VCOMP_$D(@H)_" "_$DATA(@A),VCORR="11 1" D EXAMINER
	;
NEXT	W !!,"$NEXT(@expratom)",! K ^V1A
	S ^V1A(0)=0,^(1)=1,^V1A(1,1)=11,^V1A(1000,1000)=1000000
	S ^V1A(22,66)=2266,^V1A(22,44,66)=224466,^V1A(100)=100
513	W !,"I-513  indirection of $NEXT argument"
	S ITEM="I-513  "
	S B="^V1A(0)",C="^(1)",D="^(22,1)",E="^V1A(X)",X=30
	S F="^V1A(1000)",G="^V1A(2000)"
	S VCOMP=$NEXT(@B)_" "_$N(@C)_" "_$N(@D)_" "_$N(@E)_" "_$N(@F)_" "_$N(@G)
	S VCORR="1 22 44 100 -1 -1" D EXAMINER
	;
514	W !,"I-514  indirection of subscript"
	S ITEM="I-514  "
	S A="A1",A1=0,B(1)="B(2)",B(2)=10,C="^V1A(@C(1))",C(1)="C(2)",C(2)=23
	S D="D(1)",D(1)="500"
	S VCOMP=$NEXT(^V1A(@A))_" "_$N(^(@B(1)))_" "_$N(^(22,@B(1)))_" "
	S VCOMP=VCOMP_$N(@C)_" "_$N(^V1A(@D+@D))_" "_$N(^V1A(1000+1000))
	S VCORR="1 22 44 100 -1 -1" D EXAMINER
	;
515	W !,"I-515  indirection of naked reference"
	S ITEM="I-515  ",VCOMP=""
	S A="^(2)",B="^(22,-1)",C="^(44)"
	S VCOMP=$N(^V1A(-1))_" "_$N(@A)_" "_$N(@B)_" "_$N(@C)
	S VCORR="0 22 44 66" D EXAMINER
	;
516	W !,"I-516  2 levels of indirection"
	S ITEM="I-516  ",VCOMP=""
	S A="^V1A(@A(1))",A(1)="A(2)",A(2)=-1,B="@V1A(20)",V1A(20)="^V1A(500)"
	S C="C(1)",C(1)="^V1A(22,44,-1)"
	S VCOMP=$N(@A)_" "_$N(@B)_" "_$N(@@C)
	S VCORR="0 1000 66" D EXAMINER
	;
517	W !,"I-517  3 levels of indirection"
	S ITEM="I-517  ",VCOMP=""
	S A(0)="A(1)",A(1)="A(2)",A(2)="^V1A(1000,A(3))",A(3)=20
	S B(100)="@B(200)",B(200)="@B(300)",B(300)="^V1A(22,44,50)",B(4)=100
	S VCOMP=$N(@@@A(0))_" "_$N(@B(B(4)))
	S VCORR="1000 66" D EXAMINER
	;
END	W !!,"END OF V1IDNM3",!
	S ROUTINE="V1IDNM3",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  K ^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
