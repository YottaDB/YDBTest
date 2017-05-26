V3NEW10 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"80---V3NEW10: NEW -10-"
 ;
19 S ^ABSN="30926",^ITEM="III-0926  $D(lvn)=10"
 S ^NEXT="20^V3NEW10,V3NEW11^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A(2)="A(2)",B(2)="B(2)",C(2)="C(2)"
 D NEWEXC23                               ;NEW (C,A)
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S ^VCORR="10010/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#11 1 10 1 10 1 0 0 aa(2)B(2)c(2)"
 D ^VEXAMINE
 ;
20 S ^ABSN="30927",^ITEM="III-0927  $D(lvn)=11"
 S ^NEXT="^V3NEW11,V3NEW12^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 D NEWEXC24
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;A(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;C(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCORR="0110/11 1 11 1 10 1 11 1 aa(2)bB(2)c(2)dd(2)#11 1 11 1 11 1 11 1 AA(2)bB(2)CC(2)dd(2)"
 D ^VEXAMINE
 ;
END W !!,"End of 80 --- V3NEW10",!
 K  Q
 ;
NEWEXC23 ;
 NEW (C,A)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;10010/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
NEWEXC24 ;
 NEW (B,D)
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;0110/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;10 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
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
