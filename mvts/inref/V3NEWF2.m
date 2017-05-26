V3NEWF2 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"94---V3NEWF2: NEW -24-"
 ;
47 S ^ABSN="30954",^ITEM="III-0954  Exclusive NEW"
 S ^NEXT="48^V3NEWF2,V3NEWO1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWF3
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(1))_" "      ;10 1 
 S ^VCOMP=^VCOMP_$D(A(2))_" "_$D(A(3))_" "   ;1 1 
 S ^VCOMP=^VCOMP_$D(A(4))_" "_$D(A(5))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "      ;10 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "      ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "      ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;
 I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)     ;1
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;2
 I $D(A(3))#10=1 S ^VCOMP=^VCOMP_A(3)     ;3
 I $D(A(4))#10=1 S ^VCOMP=^VCOMP_A(4)     ;
 I $D(A(5))#10=1 S ^VCOMP=^VCOMP_A(5)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S ^VCORR="101010/11 0 1 0 0 1 1 0 10 1 11 1 aa(2)5bc(2)dd(2)#10 1 1 1 0 0 10 1 10 1 0 0 123B(2)c(2)"
 D ^VEXAMINE
 ;
48 S ^ABSN="30955",^ITEM="III-0955  Selected NEW"
 S ^NEXT="^V3NEWO1,V3NEWO2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWF4
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(1))_" "      ;11 1 
 S ^VCOMP=^VCOMP_$D(A(2))_" "_$D(A(3))_" "   ;1 1 
 S ^VCOMP=^VCOMP_$D(A(4))_" "_$D(A(5))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)     ;1
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(A(3))#10=1 S ^VCOMP=^VCOMP_A(3)     ;3
 I $D(A(4))#10=1 S ^VCOMP=^VCOMP_A(4)     ;
 I $D(A(5))#10=1 S ^VCOMP=^VCOMP_A(5)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;C(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S ^VCORR="11110/11 1 1 1 0 0 11 1 10 1 11 1 a1a(2)3bB(2)c(2)dd(2)#11 1 1 1 0 0 11 1 11 1 0 0 a1a(2)3bB(2)CC(2)"
 D ^VEXAMINE
 ;
END W !!,"End of 94 --- V3NEWF2",!
 K  Q
 ;
NEWF3 ;
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;101010/
 F I=1:1:10  S A(I)=I  Q:I=5  I I=3 NEW (I,C) S I=4
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(1))_" "      ;11 0 
 S ^VCOMP=^VCOMP_$D(A(2))_" "_$D(A(3))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(A(4))_" "_$D(A(5))_" "   ;0 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "      ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "      ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "      ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)     ;
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(A(3))#10=1 S ^VCOMP=^VCOMP_A(3)     ;
 I $D(A(4))#10=1 S ^VCOMP=^VCOMP_A(4)     ;
 I $D(A(5))#10=1 S ^VCOMP=^VCOMP_A(5)     ;5
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
NEWF4 ;
 F I=1:1:10  S A(I)=I If I=3 NEW (A,B) q
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;11110/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(1))_" "      ;11 1 
 S ^VCOMP=^VCOMP_$D(A(2))_" "_$D(A(3))_" "   ;1 1 
 S ^VCOMP=^VCOMP_$D(A(4))_" "_$D(A(5))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)     ;1
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(A(3))#10=1 S ^VCOMP=^VCOMP_A(3)     ;3
 I $D(A(4))#10=1 S ^VCOMP=^VCOMP_A(4)     ;
 I $D(A(5))#10=1 S ^VCOMP=^VCOMP_A(5)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
