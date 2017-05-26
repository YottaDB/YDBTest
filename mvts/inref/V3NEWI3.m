V3NEWI3 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"117---V3NEWI3: NEW -47-"
 ;
104 S ^ABSN="31011",^ITEM="III-1011  @(""A,B"")"
 S ^NEXT="105^V3NEWI3,V3NEWI4^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWSEL21,CHECK
 S ^VCORR="000/11 1 1 0 10 1 0 0 aa(2)bc(2)#0 0 0 0 10 1 0 0 c(2)#"
 D ^VEXAMINE
 ;
105 S ^ABSN="31012",^ITEM="III-1012  @D"
 S ^NEXT="106^V3NEWI3,V3NEWI4^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C",D="B,C"
 D NEWSEL22,CHECK
 S ^VCORR="100/11 1 1 0 10 1 1 0 aa(2)bc(2)B,C#11 1 1 0 1 0 1 0 aa(2)BCB,C#"
 D ^VEXAMINE
 ;
106 S ^ABSN="31013",^ITEM="III-1013  @(""C""_"",""_""D"")"
 S ^NEXT="107^V3NEWI3,V3NEWI4^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWSEL23
 D CHECK
 S ^VCORR="10100/11 1 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#11 1 11 1 10 1 0 0 aa(2)bB(2)C(2)#"
 D ^VEXAMINE
 ;
107 S ^ABSN="31014",^ITEM="III-1014  @^VV(2)"
 S ^NEXT="^V3NEWI4,V3NEWI5^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP="",^VV(2)="A,C"
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWSEL24,CHECK
 S ^VCORR="0110/11 1 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)bB(2)CC(2)dd(2)#"
 D ^VEXAMINE k ^VV
 ;
END W !!,"End of 117 --- V3NEWI3",!
 K  K ^VV Q
 ;
NEWSEL21 ;
 N @("A,B")
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D CHECK Q
 ;
NEWSEL22 ;
 N @D
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;100/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)"
 D CHECK^V3NEWCHK Q
 ;
NEWSEL23 ;
 NEW @("C"_","_"D")
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;10100/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
NEWSEL24 ;
 N @^VV(2)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0110/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
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
 S ^VCOMP=^VCOMP_"#"
 q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
