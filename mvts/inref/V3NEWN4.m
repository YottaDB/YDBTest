V3NEWN4 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"125---V3NEWN4: NEW -55-"
 ;
133 S ^ABSN="31040",^ITEM="III-1040  all, all, all"
 S ^NEXT="134^V3NEWN4,V3NEWN5^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEW1,CHECK
 S ^VCORR="1 0 10 1 11 1 1 0 a3b(3)c3c(3)d3#1 0 10 1 11 1 1 0 a2b(2)c2c(2)d2#11 1 1 0 10 1 0 0 a1a(1)b1c(1)#10 1 10 1 10 1 0 0 A(2)B(2)C(2)#"
 D ^VEXAMINE
 ;
134 S ^ABSN="31041",^ITEM="III-1041  all, all, selective"
 S ^NEXT="135^V3NEWN4,V3NEWN5^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 s B(2)="B(2)",D="D"
 D NEW2,CHECK
 S ^VCORR="11 1 11 1 11 1 1 0 a2a(3)b3b(3)c3c(2)d3#11 1 1 0 11 1 0 0 a2a(3)b2c3c(2)#11 1 1 0 10 1 0 0 a1a(1)b1c(1)#0 0 10 1 0 0 1 0 B(2)D#"
 D ^VEXAMINE
 ;
135 S ^ABSN="31042",^ITEM="III-1042  all, all, exclusive"
 S ^NEXT="^V3NEWN5,V3NEWN6^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="11 1 0 0 0 0 0 0 a3a(3)#11 1 11 1 1 0 1 0 a3a(3)b3b(3)c3d3#11 1 1 0 10 1 0 0 a3a(3)b3c(3)#11 1 1 0 10 1 0 0 a2a(2)b2c(2)#1 0 1 0 1 0 1 0 ABCD#"
 D ^VEXAMINE
 ;
END W !!,"End of 125 --- V3NEWN4",!
 K  Q
 ;
NEW1 NEW  S A="a1",A(2)="a(1)",B="b1",C(2)="c(1)"
 D NEW1N,CHECK Q
 ;
NEW1N NEW
 S A="a2",B(2)="b(2)",C="c2",C(2)="c(2)",D="d2"
 D NEW1M,CHECK q
 ;
NEW1M N
 S A="a3",B(2)="b(3)",C="c3",C(2)="c(3)",D="d3"
 D CHECK q
 ;
NEW2 ;
 NEW
 S A="a1",A(2)="a(1)",B="b1",C(2)="c(1)"
 D NEW2N,CHECK Q
 ;
NEW2M NEW B,D
 S A(2)="a(3)",B="b3",B(2)="b(3)",C="c3",D="d3" D CHECK Q
 ;
NEW3 ;
 S A="A",B="B",C="C",D="D"
 NEW
 D SET2 D NEW3N,^V3NEWCHK Q
 ;
NEW3N ;
 NEW  K
 d SET3
 D NEW3M,CHECK Q
 ;
NEW3M ;
 NEW (A,D) d CHECK S A(2)="a(3)",B="b3",B(2)="b(3)",C="c3",D="d3"
 D CHECK^V3NEWCHK k D
 Q
SET2 S A="a2",A(2)="a(2)",B="b2",C(2)="c(2)" q
SET3 S A="a3",A(2)="a(3)",B="b3",C(2)="c(3)" q
 ;
CHECK S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "
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
 S ^VCOMP=^VCOMP_"#" Q
NEW2N ;
 NEW
 D SET2
 D NEW2M,CHECK Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
