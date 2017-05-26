V3NEWXA ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"111---V3NEWXA: NEW -41-"
 W !!,"XECUTE command after NEW command"
 ;
87 S ^ABSN="30994",^ITEM="III-0994  NEW B,C"
 S ^NEXT="88^V3NEWXA,V3NEWL1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)",^VCOMP=""
 D NEWX1,CHECK
 S ^VCORR="11 1 0 0 0 0 0 0 AA(2)#11 1 1 0 11 1 11 1 A2S C=3,A(2)=23c(2)dd(2)#11 1 11 1 11 1 11 1 A2BB(2)CC(2)dd(2)#"
 D ^VEXAMINE
 ;
88 S ^ABSN="30995",^ITEM="III-0995  NEW (B,C)"
 S ^NEXT="^V3NEWL1,V3NEWL2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP="" S A="A",B="B",C="C"
 D NEWX2,CHECK
 S ^VCORR="11 1 1 0 11 1 11 1 aa(2)bCc(2)dd(2)#0 0 11 1 0 0 11 1 bb(2)dd(2)#1 0 11 1 0 0 0 0 Abb(2)#"
 D ^VEXAMINE
 ;
END W !!,"End of 111 --- V3NEWXA",!
 K  Q
 ;
NEWX1 N B,C D CHECK S A(2)="a(2)",C(2)="c(2)",D="d",D(2)="d(2)"
 S B="S C=3,A(2)=2" X B D CHECK
 Q
 ;
NEWX2 ;
 NEW (B,C)
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 D CHECK
 S C(2)="K A,C S B(2)=""b(2)"" D CHECK" x C(2)
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
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
 S ^VCOMP=^VCOMP_"#"
