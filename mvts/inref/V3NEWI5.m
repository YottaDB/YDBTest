V3NEWI5 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"119---V3NEWI5: NEW -49-"
 ;
112 S ^ABSN="31019",^ITEM="III-1019  @""A"",@""B,C"""
 S ^NEXT="113^V3NEWI5,V3NEWI6^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWSEL31,CHECK
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#0 0 0 0 0 0 11 1 dd(2)#"
 D ^VEXAMINE
 ;
113 S ^ABSN="31020",^ITEM="III-1020  @B,@C,@A"
 S ^NEXT="114^V3NEWI5,V3NEWI6^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWSEL32,CHECK
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#1 0 1 0 1 0 11 1 ABCdd(2)#"
 D ^VEXAMINE
 ;
114 S ^ABSN="31021",^ITEM="III-1021  @^VVA,@^VVA(2)"
 S ^NEXT="115^V3NEWI5,V3NEWI6^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWSEL33,CHECK
 S ^VCORR="0100/11 1 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#10 1 11 1 10 1 0 0 A(2)bB(2)C(2)#"
 D ^VEXAMINE
 ;
115 S ^ABSN="31022",^ITEM="III-1022  @AA,@BB,@CC"
 S ^NEXT="^V3NEWI6,V3NEWI7^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWSEL34,CHECK
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)BB(2)CC(2)dd(2)#"
 D ^VEXAMINE K ^VVA
 ;
END W !!,"End of 119 --- V3NEWI5",!
 K  K ^VVA Q
 ;
NEWSEL31 ;
 new @"A",@"B,C"
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 Q
 ;
NEWSEL32 ;
 n @B,@C,@A
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 Q
 ;
NEWSEL33 ;
 S ^VVA="A",^VVA(2)="C,D"
 NEW @^VVA,@^VVA(2)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0100/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 Q
 ;
NEWSEL34 ;
 S AA="A,B",BB="B,C,A",CC="C"
 n @AA,@BB,@CC
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
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
