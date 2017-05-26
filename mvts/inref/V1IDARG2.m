V1IDARG2 ;IW-KO-MM-YS-TS,V1IDARG,MVTS V9.10;15/6/96;ARGUMENT LEVEL INDIRECTION -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"154---V1IDARG2: Argument level indirection -2-"
KILL W !!,"KILL command",!
426 W !,"I-426  Indirection of killargument" K ^V1A,^V1B
 S ^ABSN="11857",^ITEM="I-426  Indirection of killargument",^NEXT="427^V1IDARG2,V1IDARG3^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K ^V1A,^V1B K  S ^VCOMP=""
 S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9
 S %1="D",%2="E,F" K @%1 K @%2 K @^V1A(1)
 S ^VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
 S ^VCORR="11 1 1 0 0 0 0 10" D ^VEXAMINE
 ;
427 W !,"I-427  Indirection of killargument list"
 S ^ABSN="11858",^ITEM="I-427  Indirection of killargument list",^NEXT="428^V1IDARG2,V1IDARG3^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  K ^V1A,^V1B S ^VCOMP=""
 S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9,B(7)=0
 S %1="D",%2="B,E,F" K @%1,@%2,@(%1_","_%2),@^V1A(1)
 S ^VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
 S ^VCORR="11 0 1 0 0 0 0 10" D ^VEXAMINE
 ;
428 W !,"I-428  Subscript is denoted by name level indirection"
 S ^ABSN="11859",^ITEM="I-428  Subscript is denoted by name level indirection",^NEXT="429^V1IDARG2,V1IDARG3^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S ^VCOMP="" K
 S A=1,A(1)=1,A(1,1)=11,B="A(@C,@C)",C="D",D=1 K @B
 S ^VCOMP=$D(A)_" "_$D(A(1))_" "_$D(A(1,1))_"+"
 S ^V1A=1,^V1A(10)=10,^(10,30,10)=1000,^V1B(10)=30
 S ^V1B(1)="^V1A(@^V1B(2),@^V1B(3))",^(2)="^V1A(10)",^(3)="^(10)",^(4)="^V1A"
 K @^V1B(@^V1B(4))
 S ^VCOMP=^VCOMP_$D(^V1A)_" "_$D(^V1A(10))_" "_$D(^V1A(10,30,10))_" "_$D(^V1A(20))
 S ^VCORR="11 1 0+11 1 0 0" D ^VEXAMINE
 ;
429 W !,"I-429  Indirection of exclusive KILL"
 S ^ABSN="11860",^ITEM="I-429  Indirection of exclusive KILL",^NEXT="430^V1IDARG2,V1IDARG3^V1IDARG,V1XECA^VV1" D ^V1PRESET
 S ^VCOMP="" K  K ^V1A,^V1B
 S (A,B,C,D,E,F)=1,A(1)=1,A(1,1)=11,^V1A(1)="^V1A",^V1B(9)=9,B(7)=0
 S A="(B),D,E" K @A
 S ^VCOMP=$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(^V1A)_" "_$D(^V1B)
 S ^VCORR="0 11 0 0 0 0 10 10" D ^VEXAMINE
 ;
430 W !,"I-430  Value of indirection contains indirection"
 S ^ABSN="11861",^ITEM="I-430  Value of indirection contains indirection",^NEXT="V1IDARG3^V1IDARG,V1XECA^VV1" D ^V1PRESET
 K  S (A,B,B(1),B(1,1),B(2),B(2,2,2),B(3,3),C)=1
 S Z="@A(1),@B(1)",A(1)="A(2)",B(1)="B(2),B(3)"
 K @Z,Z
 S ^VCOMP=$D(A)_" "_$D(B)_" "_$D(B(1))_" "_$D(B(1,1))_" "
 S ^VCOMP=^VCOMP_$D(B(2))_" "_$D(B(2,2,2))_" "_$D(B(3,3))_" "_$D(C)
 S ^VCORR="11 11 11 1 0 0 0 1" D ^VEXAMINE
 ;
END W !!,"End of 154---V1IDARG2",!
 K  K ^V1A,^V1B Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
