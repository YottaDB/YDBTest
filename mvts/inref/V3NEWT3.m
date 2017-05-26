V3NEWT3 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"107---V3NEWMT3: NEW -37-"
 W !!,"3 times"
 ;
79 S ^ABSN="30986",^ITEM="III-0986  $D(lvn)=0"
 S ^NEXT="80^V3NEWT3,V3NEWT4^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWT31,CHECK
 S ^VCORR="11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 10 1 1 0 0 0 aaaa(2)bb(2)cc#11 1 11 1 10 1 1 0 aaAA(2)BBbb(2)CC(2)DD#11 1 1 0 0 0 0 0 aaAA(2)b#"
 D ^VEXAMINE
 ;
80 S ^ABSN="30987",^ITEM="III-0987  $D(lvn)=1"
 S ^NEXT="^V3NEWT4,V3NEWML1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWT32,CHECK
 S ^VCORR="11 1 1 0 11 1 1 0 aa(2)bCc(2)d#10 1 11 1 11 1 10 1 aa(2)bbb(2)Ccc(2)dd(2)#11 1 1 0 10 1 11 1 AA(2)BC(2)DD(2)#11 1 1 0 11 1 1 0 aa(2)BCcc(2)d#"
 D ^VEXAMINE
 ;
END W !!,"End of 107 --- V3NEWT3",!
 K  Q
 ;
NEWT31 ;
 N (A,B)
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 NEW C,B kill D
 S A="aa",A(2)="aa(2)",B(2)="bb(2)",C="cc"
 D CHECK
 nEW (A,B)
 S A(2)="AA(2)",B="BB",C(2)="CC(2)",D="DD"
 D CHECK
 Q
 ;
NEWT32 ;
 NEW B
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d"
 D CHECK
 N (B,C)
 S A(2)="aa(2)",B(2)="bb(2)",C(2)="cc(2)",D(2)="dd(2)"
 D CHECK
 N  S A="A",A(2)="A(2)",B="B",C(2)="C(2)",D="D",D(2)="D(2)"
 D CHECK
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
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
