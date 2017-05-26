V3NEWDO1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"99---V3NEWDO1: NEW -29-"
 W !!,"internal DO command"
 ;
57 S ^ABSN="30964",^ITEM="III-0964  NEW all"
 S ^NEXT="58^V3NEWDO1,V3NEWDO2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C" s D=32 k D
 D NEWDO1
 D CHK
 S ^VCORR="111/0 0 0 0 0 0 0 0 11 1 11 1 11 1 11 1 aa(2)bBB(2)CCc(2)dd(2)#1 0 1 0 1 0 0 0 ABC#"
 D ^VEXAMINE
 ;
58 S ^ABSN="30965",^ITEM="III-0965  selective NEW"
 S ^NEXT="59^V3NEWDO1,V3NEWDO2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 S ^VCOMP=""
 D NEWDO2,CHK
 S ^VCORR="0011/11 1 1 0 11 1 11 1 aa(2)bCc(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)BB(2)Cc(2)dd(2)#"
 D ^VEXAMINE
 ;
59 S ^ABSN="30966",^ITEM="III-0966  exclusive NEW"
 S ^NEXT="^V3NEWDO2,V3NEWMF1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 S ^VCOMP=""
 D NEWDO3,CHK
 S ^VCORR="111111/0 0 11 1 0 0 0 0 11 1 11 1 11 1 11 1 aa(2)bBB(2)CCc(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)bBB(2)CC(2)dd(2)#"
 D ^VEXAMINE
 ;
END W !!,"End of 99 --- V3NEWDO1",!
 K  Q
 ;
NEWDO1 ;
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111/
 N  d NEWDOE1
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHK
 Q
 ;
NEWDO3 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111111/
 N (B,D) d NEWDOE1
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHK
 Q
 ;
NEWDOE1 ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "
 S A="AA",A(2)="AA(2)",B="BB",B(2)="BB(2)",C="CC",C(2)="CC(2)"
 Q
 ;
NEWDO2 ;
 N A,B
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0011/
 D NEWDOE2
 S D="d",D(2)="d(2)"
 D CHK
 q
 ;
CHK ;
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
 ;
NEWDOE2 S A="a",A(2)="a(2)",B="b",B(2)="b(2)",C(2)="c(2)"
 KILL B(2)
 Q
 ;
