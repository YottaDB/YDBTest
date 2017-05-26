V3NEWMF1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"101---V3NEWMF1: NEW -31-"
 W !!,"duplicated NEW by FOR command" 
 ;
63 S ^ABSN="30970",^ITEM="III-0970  FOR I=1:1:4 ... NEW"
 S ^NEXT="64^V3NEWMF1,V3NEWMF2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWF1,CHECK
 S ^VCORR="101010/11 0 1 0 0 0 1 0 10 1 0 0 aa(2)bc(2)#10 1 1 0 0 0 10 1 10 1 0 0 1A(2)B(2)C(2)#"
 D ^VEXAMINE K ^VV
 ;
64 S ^ABSN="30971",^ITEM="III-0971  FOR I=1:1:4 ... NEW A,B"
 S ^NEXT="65^V3NEWMF1,V3NEWMF2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWF2,CHECK
 S ^VCORR="000/11 0 1 0 0 0 1 0 10 1 0 0 aa(2)bc(2)#10 1 0 0 0 0 0 0 10 1 0 0 1c(2)#"
 D ^VEXAMINE
 ;
65 S ^ABSN="30972",^ITEM="III-0972  FOR I=1:1:4 ... NEW (I,B)"
 S ^NEXT="^V3NEWMF2,V3NEWMF3^V3NEW,V3ALDO^VV3" D ^V3PRESET K  S ^VCOMP=""
 S A="A",A(1)="A(1)",A(2)="A(2)",A(3)="A(3)",A(4)="A(4)",A(5)="A(5)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWF3,CHECK
 S ^VCORR="111111/11 0 1 0 0 0 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#11 1 1 1 1 1 11 1 11 1 0 0 A1A(2)A(3)A(4)A(5)bB(2)CC(2)#"
 D ^VEXAMINE
 ;
END W !!,"End of 101 --- V3NEWMF1",!
 K  K ^VV Q
 ;
NEWF1 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;101010/
 F I=1:1:4 S ^VV=I S A(I)=I N  S I=^VV
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)" G CHECK
 ;
NEWF2 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
 F I=1:1:4 S A(I)=I NEW A,B
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)" D CHECK Q
 ;
NEWF3 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111111/
 F I=1:1:4 S A(I)=I NEW (I,B)
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK Q
 ;
CHECK S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(1))_" "
 S ^VCOMP=^VCOMP_$D(A(2))_" "_$D(A(3))_" "
 S ^VCOMP=^VCOMP_$D(A(4))_" "_$D(A(5))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A
 I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)
 I $D(A(3))#10=1 S ^VCOMP=^VCOMP_A(3)
 I $D(A(4))#10=1 S ^VCOMP=^VCOMP_A(4)
 I $D(A(5))#10=1 S ^VCOMP=^VCOMP_A(5)
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
