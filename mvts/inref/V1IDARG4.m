V1IDARG4 ;IW-KO-MM-YS-TS,V1IDARG,MVTS V9.10;15/6/96;ARGUMENT LEVEL INDIRECTION -4-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"156---V1IDARG4: Argument level indirection -4-"
SET W !!,"SET command",!
435 W !,"I-435  Indirection of setargument"
 S ^ABSN="11866",^ITEM="I-435  Indirection of setargument",^NEXT="436^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K ^V1A,^V1B
 S ^VCOMP="" S A="A=0" S @A S ^VCOMP=^VCOMP_A
 S ^VCORR="0" D ^VEXAMINE
 ;
436 W !,"I-436  Indirection of setargument list"
 S ^ABSN="11867",^ITEM="I-436  Indirection of setargument list",^NEXT="437^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S VCOMP="" S A="P=1",B="Q=B=B+1,R=3" S @A,@B,@("S="_4)
 S VCOMP=VCOMP_P_Q_R_S
 S ^VCOMP=VCOMP,^VCORR="1234" D ^VEXAMINE
 ;
437 W !,"I-437  Indirection of multiple-assignment"
 S ^ABSN="11868",^ITEM="I-437  Indirection of multiple-assignment",^NEXT="438^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S ^VCOMP="" S B="C",A="(A,@B)=8",C="A",@@C
 S ^VCOMP=A_C
 S ^VCORR="88" D ^VEXAMINE
 ;
438 W !,"I-438  2 levels of setargument indirection"
 S ^ABSN="11869",^ITEM="I-438  2 levels of setargument indirection",^NEXT="439^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S ^VCOMP="" S A="T=5",B="U=6",C="@A,@B",@C,^VCOMP=^VCOMP_T_U
 S ^VCORR="56" D ^VEXAMINE
 ;
439 W !,"I-439  3 levels of setargument indirection"
 S ^ABSN="11870",^ITEM="I-439  3 levels of setargument indirection",^NEXT="440^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S VCOMP=""
 S A="Q(1)=10",B="^V1A(10)=100,^(20)=""QUIT """,C="@A,(M(1),M(2))=20,M=200,@B"
 S D="@C,N(1)=0.001",@D
 S VCOMP=Q(1)_^V1A(10)_^V1A(20)_M(1)_M(2)_M_N(1)
 S ^VCOMP=VCOMP,^VCORR="10100QUIT 2020200.001" D ^VEXAMINE
 ;
440 W !,"I-440  Value of indirection contains name level indirection"
 S ^ABSN="11871",^ITEM="I-440  Value of indirection contains name level indirection",^NEXT="441^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S A="@A(1)=$J(987.6E-2,6,2),@B(1)=@B(2)",A(1)="A(2)",B(1)="C(10)",B(2)="B(3)",B(3)="SET"
 S @A,^VCOMP=A(2)_" "_C(10),^VCORR="  9.88 SET" D ^VEXAMINE
 ;
441 W !,"I-441  Value of indirection contains operators"
 S ^ABSN="11872",^ITEM="I-441  Value of indirection contains operators",^NEXT="442^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S VCOMP=""
 S A="B",B="C",C=3,D="@(""V=@B+1+""_"_"B"_")" S @D
 S ^VCOMP=VCOMP_V,^VCORR="7" D ^VEXAMINE
 ;
442 W !,"I-442  Value of indirection is function"
 S ^ABSN="11873",^ITEM="I-442  Value of indirection is function",^NEXT="443^V1IDARG4,V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S ^V1A(2)="@($P(""^V1A(I)/^V1B(I)/^V1C(I)/^V1D(I)"",""/"",I))=I_"" """
 F I=1,3 S:I @^V1A(2)
 S ^VCOMP=^V1A(1)_^V1C(3) S ^VCORR="1 3 " D ^VEXAMINE
 ;
443 W !,"I-443  Value of indirection contains subscripted local variable"
 S ^ABSN="11874",^ITEM="I-443  Value of indirection contains subscripted local variable",^NEXT="V1IDARG5^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S VCOMP=""
 S ^V1A(1,2)="A(1,2,3)=123,%A(A,@B,@@C)=@D_@C",A=1.00,B="B(1)",B(1)=2
 S C="C(1)",C(1)="C(2)",C(2)="3",D="D(1,1,1,1)",D(1,1,1,1)="LOCAL"_'0
 S @^V1A(1,2)
 S ^VCOMP=A(1,2,3)_" "_%A(1,2,3),^VCORR="123 LOCAL1C(2)" D ^VEXAMINE
 ;
END W !!,"End of 156---V1IDARG4",!
 K  K ^V1A,^V1C Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
