V3NEWN1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"122---V3NEWN1: NEW -52-"
 W !!,"Nesting tests"
 ;
124 S ^ABSN="31031",^ITEM="III-1031  all, all"
 S ^NEXT="125^V3NEWN1,V3NEWN2^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEW1,CHECK
 S ^VCORR="11 1 1 0 10 1 0 0 aa(2)bc(2)#1 0 10 1 11 1 1 0 xy(2)zz(2)w#11 1 1 0 10 1 0 0 aa(2)bc(2)#10 1 10 1 10 1 0 0 A(2)B(2)C(2)#"
 D ^VEXAMINE
 ;
125 S ^ABSN="31032",^ITEM="III-1032  all, selective"
 S ^NEXT="126^V3NEWN1,V3NEWN2^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 s B(2)="B(2)",D="D"
 D NEW2,CHECK
 S ^VCORR="11 1 1 0 10 1 0 0 aa(2)bc(2)#11 1 0 0 10 1 0 0 aa(2)c(2)#11 1 11 1 11 1 0 0 aa(3)b3b(3)c3c(2)#11 1 1 0 11 1 0 0 aa(3)bc3c(2)#0 0 10 1 0 0 1 0 B(2)D#"
 D ^VEXAMINE
 ;
126 S ^ABSN="31033",^ITEM="III-1033  all, exclusive"
 S ^NEXT="^V3NEWN2,V3NEWN3^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 D NEW3,CHECK
 S ^VCORR="11 1 1 0 10 1 10 1 aa(2)bc(2)d(2)#11 1 0 0 0 0 10 1 aa(2)d(2)#11 1 11 1 1 0 11 1 aa(3)b3b(3)c3d3d(2)#11 1 1 0 10 1 0 0 aa(3)bc(2)#1 0 1 0 1 0 1 0 ABCD#"
 D ^VEXAMINE
 ;
END W !!,"End of 122 --- V3NEWN1",!
 K  Q
 ;
NEW1 NEW  S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D CHECK,NEW1N,CHECK Q
 ;
NEW1N NEW
 S A="x",B(2)="y(2)",C="z",C(2)="z(2)",D="w"
 D CHECK q
 ;
NEW2 ;
 NEW
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D CHECK,NEW2N,CHECK
 Q
 ;
NEW2N NEW B,D
 D CHECK
 S A(2)="a(3)",B="b3",B(2)="b(3)",C="c3"
 D CHECK
 Q
 ;
NEW3 ;
 S A="A",B="B",C="C",D="D"
 NEW
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D(2)="d(2)"
 D CHECK^V3NEWCHK,NEW3N,^V3NEWCHK
 Q
 ;
NEW3N ;
 NEW (A,D) d CHECK S A(2)="a(3)",B="b3",B(2)="b(3)",C="c3",D="d3"
 D CHECK^V3NEWCHK k D
 Q
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
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
