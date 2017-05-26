V1IDARG1	;ARGUMENT LEVEL INDIRECTION -1-;KO-MM-YS-TS,V1IDARG,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDARG1: TEST OF ARGUMENT LEVEL INDIRECTION -1-",!
IF	W !,"IF command",!
417	W !,"I-417  indirection of ifargument"
	S ITEM="I-417  ",VCOMP=""
	S A=1 I @A S VCOMP=1 I  S VCOMP=VCOMP_" "_$T_"/"
	E  S VCOMP=VCOMP_"ERROR 417.1"
	S A="1=0" I @A S VCOMP=VCOMP_"ERROR 417.2"
	E  S VCOMP=VCOMP_2
	S VCOMP=VCOMP_" "_$T_"/"
	S B="1=1",D="B" I @D S VCOMP=VCOMP_3 I  S VCOMP=VCOMP_" "_$T
	E  S VCOMP=VCOMP_"ERROR 417.3"
	S VCORR="1 1/2 0/3 1" D EXAMINER
	;
418	W !,"I-418  indirection of ifargument list"
	S ITEM="I-418  ",VCOMP=""
	S A="1=1,0" I @A S VCOMP=VCOMP_"ERROR 418 " I  S VCOMP=VCOMP_"ERROR 418.1 "
	E  S VCOMP=VCOMP_"418 "_$T
	S VCORR="418 0" D EXAMINER
	;
419	W !,"I-419  list of indirection and ifargument"
	S ITEM="I-419  ",VCOMP=""
	S B="00.1,2",C="$E(123,2)",D="1,0"
	IF 1.0,B,@B,@C S VCOMP=VCOMP_"419.1 "_$T
	E  S VCOMP=VCOMP_" ERROR 419.1 "_$T
	IF +D,2>1,@B,@C,@D S VCOMP=VCOMP_" ERROR 419.2 "_$T
	E  S VCOMP=VCOMP_" 419.2 "_$T
	S VCORR="419.1 1 419.2 0" D EXAMINER
	;
420	W !,"I-420  2 levels of ifargument indirection"
	S ITEM="I-420  ",V=""
	S A="@A(1)",A(1)="$E(A(2),2,3)+0",A(2)=9876
	S ^V1A(100)="^V1A(2)",^(2)="^(3)=""ABCD""",^(3)="ABCD"
	I @A S V=V_"4201 " I @@^V1A(100) S V=V_"42011 "
	E  S V=V_" ERROR 420.1 "
	S V=V_$T_"/"
	S A(2)=2000 I @A S V=V_" ERROR 420.2 "
	E  S V=V_"4202 "
	S V=V_$T
	S VCOMP=V,VCORR="4201 42011 1/4202 0" D EXAMINER
	;
421	W !,"I-421  3 levels of ifargument indirection"
	S ITEM="I-421  ",VCOMP=""
	S A="@A(1)",A(1)="@A(2)",A(3)="123.456E-2>A(4)",A(4)="0001.5000"
	K ^V1A S ^V1A(2)="B(2)",B(2)="^V1A(3)",^V1A(3)="""AB23E""?2A.N1A"
	I @A,0.002 S VCOMP=VCOMP_"AA " I 1,@@@^V1A(2) S VCOMP=VCOMP_"BB "
	E  S VCOMP=VCOMP_"E1 "
	S VCORR="AA BB " D EXAMINER
	;
422	W !,"I-422  Value of indirection expratom contains operator"
	S ITEM="I-422  ",VCOMP="" K ^V1A
	S ^V1A(101)="""DOG""[^V1A(3)",^V1A(3)="G"
	I @^V1A(101) S VCOMP=VCOMP_"DOGS "
	E  S VCOMP=VCOMP_"CATS "
	S ^V1A(3)="C" I @^V1A(101) S VCOMP=VCOMP_"NOT CATS"
	E  S VCOMP=VCOMP_"CATS"
	S VCORR="DOGS CATS" D EXAMINER
	;
423	W !,"I-423  Value of indirection expratom is function"
	S ITEM="I-423  ",VCOMP=""
	S A(1,1,1)="$L($P(""A-B-CCC-EFD-55555"",@B,I))=I",B="C",C="-"
	F I=1:1:5 I @A(1,1,1) S VCOMP=VCOMP_I_" "
	S VCORR="1 3 5 " D EXAMINER
	;
424	W !,"I-424  Value of indirection expratom contains indirection"
	S ITEM="I-424  ",VCOMP=""
	S A(1)="123=@B(@A(2))",B(1)="@C",C="D",D=22,A(2)="A(3)",A(3)=1
	I @A(@A(2)) S VCOMP=VCOMP_"A "
	E  S VCOMP=VCOMP_"AAE "
	S VCORR="AAE " D EXAMINER
	;
425	W !,"I-425  Value of indirection expratom subscripted variable name"
	S ITEM="I-425  ",VCOMP=""
	S A(1)="A(@B,@B(2)),@B",B="B(1)",B(1)=2,B(2)="@B(3)",B(3)="B(4)",B(4)=3
	S A(2,3)=0.23E-3 I @A(1) S VCOMP=VCOMP_"A "
	E  S VCOMP=VCOMP_"AAE "
	S A(2,3)="0.00E+2=1" IF @A(1) S VCOMP=VCOMP_"BBE "
	E  S VCOMP=VCOMP_"B "
	S VCORR="A B " D EXAMINER
	;
END	W !!,"END OF V1IDARG1",!
	S ROUTINE="V1IDARG1",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  K ^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
