V3NEWN3 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"124---V3NEWN3: NEW -54-"
 ;
130 S ^ABSN="31037",^ITEM="III-1037  exclusive, all"
 S ^NEXT="131^V3NEWN3,V3NEWN4^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A="A1",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 D NEW1,CHECK
 S ^VCORR="1 0 11 1 1 0 11 1 abB(1)cdD(1)0 0 10 1 11 1 1 0 b(3)c3c(3)d31 0 11 1 1 0 11 1 abB(1)cdD(1)11 1 11 1 11 1 11 1 A1A(1)bB(1)C1C(1)dD(1)"
 D ^VEXAMINE
 ;
131 S ^ABSN="31038",^ITEM="III-1038  exclusive, selective"
 S ^NEXT="132^V3NEWN3,V3NEWN4^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A="A1",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 S ^VVA(11)="B"
 D NEW2,CHECK
 S ^VCORR="11 1 11 1 10 1 11 1 aa(2)bB(1)c(2)D1D(1)11 1 11 1 0 0 11 1 aa(2)bB(1)D1D(1)11 1 11 1 10 1 11 1 a3a(3)b3B(1)c(3)D1D(1)11 1 11 1 10 1 11 1 a3a(3)b3B(1)c(2)D1D(1)11 1 11 1 11 1 11 1 A1A(1)b3B(1)C1C(1)D1D(1)"
 D ^VEXAMINE
 ;
132 S ^ABSN="31039",^ITEM="III-1039  exclusive, exclusive"
 S ^NEXT="^V3NEWN4,V3NEWN5^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="0 0 11 1 0 0 11 1 B1B(1)D1D(1)11 1 11 1 10 1 11 1 @$C(66)(@A,D)AB(1)c(2)D1D(1)0 0 11 1 0 0 11 1 AB(1)D1D(1)11 1 11 1 10 1 10 1 a3a(3)b3B(1)c(3)d(3)11 1 11 1 10 1 10 1 @$C(66)(@A,D)b3B(1)c(2)d(3)11 1 11 1 11 1 10 1 (D,B)A(1)b3B(1)C1C(1)d(3)"
 D ^VEXAMINE
 ;
END W !!,"End of 124 --- V3NEWN3",!
 K  K ^VVA Q
 ;
NEW1 ;
 NEW (D,B)
 S A="a",B="b",C="c",D="d"
 D CHECK D NEW1N D CHECK Q
 ;
NEW1N ;
 NEW
 S B(2)="b(3)",C="c3",C(2)="c(3)",D="d3"
 D CHECK Q
 ;
NEW2 ;
 NEW (@$P("A,B,C,D,E,F,G",",",4),@^VVA($D(C))) ;(D,B)  A,C
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D CHECK
 D NEW2N D CHECK Q
NEW2N N C D CHECK S A="a3",A(2)="a(3)",B="b3",C(2)="c(3)" D CHECK Q
 ;
NEW3 ;
 S A="(D,B)",A(2)="A(1)",B="B1",B(2)="B(1)",C="C1",C(2)="C(1)",D="D1",D(2)="D(1)"
 NEW @A ;N A,C
 D CHECK
 S A="@$C(66)",A(2)="(@A,D)",B="A",C(2)="c(2)"
 D CHECK,NEW3N,CHECK Q
 ;
NEW3N ;
 N @@B@(2) ;(B,D) A,C
 D CHECK k D
 S A="a3",A(2)="a(3)",B="b3",C(2)="c(3)",D(2)="d(3)"
 D CHECK q
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
 S ^VCOMP=^VCOMP_"" Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
