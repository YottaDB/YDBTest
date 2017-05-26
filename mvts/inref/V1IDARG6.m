V1IDARG6 ;IW-KO-MM-YS-TS,V1IDARG,MVTS V9.10;15/6/96;ARGUMENT LEVEL INDIRECTION -6-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"158---V1IDARG6: Argument level indirection -6-"
XECUTE W !!,"XECUTE command",!
453 W !,"I-453  Indirection of xecuteargument"
 S ^ABSN="11884",^ITEM="I-453  Indirection of xecuteargument",^NEXT="454^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP="" S A="B",B="S VCOMP=1" XECUTE @A
 S G="""S VCOMP=VCOMP_2"",H",H="S VCOMP=VCOMP_3" X @G
 S ^VCOMP=VCOMP,^VCORR="123" D ^VEXAMINE
 ;
454 W !,"I-454  Indirection of xecuteargument list"
 S ^ABSN="11885",^ITEM="I-454  Indirection of xecuteargument list",^NEXT="455^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S ^VCOMP=""
 S A="B",B="S ^VCOMP=^VCOMP+1",C="""SET ^VCOMP=^VCOMP+10,^VCOMP=^VCOMP/100"""
 X @A,@C S ^VCORR=".11" D ^VEXAMINE
 ;
455 W !,"I-455  2 levels of xecuteargument indirection"
 S ^ABSN="11886",^ITEM="I-455  2 levels of xecuteargument indirection",^NEXT="456^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP="",A="%",%="X @C(1),@C(1)",C(1)="C"
 S C="SET VCOMP=VCOMP_""1 "",%=0,C=""S VCOMP=VCOMP_""""! """"""" X @A
 S VCOMP=VCOMP_%,^VCOMP=VCOMP,^VCORR="1 ! 0" D ^VEXAMINE
 ;
456 W !,"I-456  3 levels of xecuteargument indirection"
 S ^ABSN="11887",^ITEM="I-456  3 levels of xecuteargument indirection",^NEXT="457^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP=""
 S B(0)="B",B="X B(1),@B(22)",B(1)="S A=1,A(1,2)=12",B(22)="B(2)"
 S B(2)="X B(3),@B(44),B(5)",B(3)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))_"" ""_$D(A(1,2))"
 S B(44)="B(4)",B(4)="K A(1) S:1 VCOMP=VCOMP_""/""",B(5)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))_"" ""_$D(A(1,2))"
 X @B(0) S ^VCOMP=VCOMP,^VCORR="11 10 1/1 0 0" D ^VEXAMINE
 ;
457 W !,"I-457  Value of indirection contains name level indirection"
 S ^ABSN="11888",^ITEM="I-457  Value of indirection contains name level indirection",^NEXT="458^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP="" S C="@D",D="@E",E="F",F="S VCOMP=457" X @C
 S ^VCOMP=VCOMP,^VCORR="457" D ^VEXAMINE
 ;
458 W !,"I-458  Value of indirection contains operators"
 S ^ABSN="11889",^ITEM="I-458  Value of indirection contains operators",^NEXT="459^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S B(2)=10,K=100,^V1(K)="""S (A""_$E(""QWER"",2,3)_"",B(1),B(2))=B(2)+10"""
 X @^V1(K) S VCOMP=AWE_B(1)_B(2)
 S ^VCOMP=VCOMP,^VCORR="202020" D ^VEXAMINE
 ;
459 W !,"I-459  Value of indirection contains function"
 S ^ABSN="11890",^ITEM="I-459  Value of indirection contains function",^NEXT="460^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(2)="$S(12>23:""S VCOMP=VCOMP_$L(2)"",90<91:""S VCOMP=VCOMP_$L(32)"")"
 XECUTE @^V1(2)
 S ^VCOMP=VCOMP,^VCORR="2" D ^VEXAMINE
 ;
460 W !,"I-460  Value of indirection contains argument level indirection"
 S ^ABSN="11891",^ITEM="I-460  Value of indirection contains argument level indirection",^NEXT="855^V1IDARG6,V1XECA^VV1" D ^V1PRESET
 S VCOMP=""
 S A="VCOMP=$P(""SET/TEST/LET"",""/"",2),A(1)=100",Z="S @A",B="C",C=1,Z(1)="Z"
 X:@B @Z(1) S VCOMP=VCOMP_A(1)
 S ^VCOMP=VCOMP,^VCORR="TEST100" D ^VEXAMINE
 ;
855 W !,"I-855  Transition of $DATA from 11 to 1 after KILLing the only descendent"
 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
 S ^ABSN="12156",^ITEM="I-855  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="V1XECA^VV1" D ^V1PRESET
 S B(0)="B",B="X B(1),@B(22)",B(1)="S A=1,A(1,2)=12",B(22)="B(2)",VCOMP="" K A
 S B(2)="X B(3),@B(44),B(5)",B(3)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))_"" ""_$D(A(1,2))"
 S B(44)="B(4)",B(4)="K A(1,2) S:1 VCOMP=VCOMP_""/""",B(5)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))_"" ""_$D(A(1,2))"
 X @B(0) S ^VCOMP=VCOMP,^VCORR="11 10 1/1 0 0" D ^VEXAMINE
 ;
END W !!,"End of 158---V1IDARG6",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
