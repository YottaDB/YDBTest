V1IDARG3	;ARGUMENT LEVEL INDIRECTION -3-;KO-MM-YS-TS,V1IDARG,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDARG3: TEST OF ARGUMENT LEVEL INDIRECTION -3-"
SET	W !!,"SET command",! K ^V1A,^V1B
435	W !,"I-435  indirection of setargument"
	S ITEM="I-435  ",VCOMP="" S A="A=0" S @A S VCOMP=VCOMP_A
	S VCORR="0" D EXAMINER
	;
436	W !,"I-436  indirection of setargument list"
	S ITEM="I-436  ",VCOMP=""
	S A="P=1",B="Q=B=B+1,R=3" S @A,@B,@("S="_4)
	S VCOMP=VCOMP_P_Q_R_S
	S VCORR="1234" D EXAMINER
	;
437	W !,"I-437  indirection of multi-assignment"
	S ITEM="I-437  ",VCOMP=""
	S B="C",A="(A,@B)=8",C="A",@@C
	S VCOMP=A_C
	S VCORR="88" D EXAMINER
	;
438	W !,"I-438  2 levels of setargument indirection"
	S ITEM="I-438  ",VCOMP=""
	S A="T=5",B="U=6",C="@A,@B",@C,VCOMP=VCOMP_T_U
	S VCORR="56" D EXAMINER
	;
439	W !,"I-439  3 levels of setargument indirection"
	S ITEM="I-439  ",VCOMP=""
	S A="Q(1)=10",B="^V1A(10)=100,^(20)=""QUIT """,C="@A,(M(1),M(2))=20,M=200,@B"
	S D="@C,N(1)=0.001",@D
	S VCOMP=Q(1)_^V1A(10)_^V1A(20)_M(1)_M(2)_M_N(1)
	S VCORR="10100QUIT 2020200.001" D EXAMINER
	;
440	W !,"I-440  Value of indirection contains name level indirection"
	S ITEM="I-440  "
	S A="@A(1)=$J(987.6E-2,6,2),@B(1)=@B(2)",A(1)="A(2)",B(1)="C(10)",B(2)="B(3)",B(3)="SET"
	S @A,VCOMP=A(2)_" "_C(10),VCORR="  9.88 SET" D EXAMINER
	;
441	W !,"I-441  Value of indirection contains operators"
	S ITEM="I-441  ",VCOMP=""
	S A="B",B="C",C=3,D="@(""V=@B+1+""_"_"B"_")" S @D
	S VCOMP=VCOMP_V,VCORR="7" D EXAMINER
	;
442	W !,"I-442  Value of indirection is function"
	S ITEM="I-442  "
	S ^V1A(2)="@($P(""^V1A(I)/^V1B(I)/^V1C(I)/^V1D(I)"",""/"",I))=I_"" """
	F I=1,3 S:I @^V1A(2)
	S VCOMP=^V1A(1)_^V1C(3) S VCORR="1 3 " D EXAMINER
	;
443	W !,"I-443  Value of indirection contains subscripted local variable" K (PASS,FAIL)
	S ITEM="I-443  ",VCOMP=""
	S ^V1A(1,2)="A(1,2,3)=123,%A(A,@B,@@C)=@D_@C",A=1.00,B="B(1)",B(1)=2
	S C="C(1)",C(1)="C(2)",C(2)="3",D="D(1,1,1,1)",D(1,1,1,1)="LOCAL"_'0
	S @^V1A(1,2)
	S VCOMP=A(1,2,3)_" "_%A(1,2,3),VCORR="123 LOCAL1C(2)" D EXAMINER
	;
END	W !!,"END OF V1IDARG3",!
	S ROUTINE="V1IDARG3",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  K ^V1A,^V1B,^V1C,^V1D Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
