V3NEWN12 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"133---V3NEWN12: NEW -63-"
 ;
157 S ^ABSN="31064",^ITEM="III-1064  exclusive, exclusive, all"
 S ^NEXT="158^V3NEWN12,END^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW1,CHECK
 S ^VCORR="0 0 10 1 11 1 1 0 b(3)c3c(3)d3#1 0 11 1 1 0 11 1 abB(1)cdD(1)#11 1 11 1 11 1 11 1 A1A(1)bB(1)C1C(1)dD(1)#11 1 11 1 11 1 1 0 A1A(1)bB(1)C1C(1)D#"
 D ^VEXAMINE
 ;
158 S ^ABSN="31065",^ITEM="III-1065  exclusive, exclusive, selective"
 S ^NEXT="159^V3NEWN12,END^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A="A1",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 S ^VVA(11)="B"
 D NEW2,CHECK
 S ^VCORR="11 1 11 1 10 1 11 1 a3a(3)b3B(1)c(3)D1D(1)#11 1 11 1 10 1 11 1 a3a(3)b3B(1)c(2)D1D(1)#11 1 11 1 11 1 11 1 A1A(1)b3B(1)C1C(1)D1D(1)#11 1 11 1 11 1 11 1 A1A(1)b3B(1)C1C(1)D1D(1)#"
 D ^VEXAMINE
 ;
159 S ^ABSN="31066",^ITEM="III-1066  exclusive, exclusive, exclusive"
 S ^NEXT="END^V3NEWN12,END^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="11 1 11 1 10 1 10 1 a3a(3)b3B(1)c(3)d(3)#11 1 11 1 10 1 10 1 @$C(66)(@A,D)b3B(1)c(2)d(3)#11 1 11 1 11 1 10 1 (D,B)A(1)b3B(1)C1C(1)d(3)#1 0 10 1 11 1 10 1 ab(0)C1C(1)d(3)#"
 D ^VEXAMINE
 ;
END W !!,"End of 133 --- V3NEWN12",!
 K  K ^VVA Q
 ;
NEW1 ;
 S A="A",B="B",C="C",D="D"
 NEW (A,B,C)
 S A="A1",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 D NEW1N,^V3NEWCHK Q
 ;
NEW1N NEW (D,B) S A="a",B="b",C="c",D="d" D NEW1M D CHECK Q
 ;
NEW1M ;
 NEW
 S B(2)="b(3)",C="c3",C(2)="c(3)",D="d3" D CHECK Q
 ;
NEW2 ;
 NEW (A,B)
 S A="A1",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 D NEW2N,^V3NEWCHK Q
 ;
NEW2N ;
 NEW (D,B)
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D NEW2M D CHECK Q
NEW2M N C S A="a3",A(2)="a(3)",B="b3",C(2)="c(3)" D CHECK Q
 ;
NEW3 ;
 S A="a",B(2)="b(0)",C="c",C(2)="c(0)"
 NEW (C,D)
 S A="A",B="B",C="C",D="D" D NEW3N,CHECK q
 ;
NEW3N ;
 S A="(D,B)",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 NEW @A ;N A,C
 S A="@$C(66)",A(2)="(@A,D)",B="A",C(2)="c(2)" D NEW3M,CHECK Q
 ;
NEW3M ;
 N @@B@(2) ;(B,D) A,C
 k D S A="a3",A(2)="a(3)",B="b3",C(2)="c(3)",D(2)="d(3)"
 g ^V3NEWCHK
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
CHECK ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)
 S ^VCOMP=^VCOMP_"#"
