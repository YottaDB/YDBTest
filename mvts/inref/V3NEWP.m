V3NEWP ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"97---V3NEWWP: NEW -27-"
 W !!,"NEW command with postcondition"
 ;
53 S ^ABSN="30960",^ITEM="III-0960  postcond is true"
 S ^NEXT="54^V3NEWP,V3NEWX^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 D NEWP1
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S ^VCORR="000/11 1 1 0 10 1 11 1 aa(2)bc(2)dd(2)#0 0 0 0 0 0 0 0 "
 D ^VEXAMINE
 ;
54 S ^ABSN="30961",^ITEM="III-0961  postcond is false"
 S ^NEXT="^V3NEWX,V3NEWDO1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C" s D=32 k D
 D NEWP2                                  ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S ^VCORR="011/11 1 1 0 11 1 11 1 aa(2)bCc(2)dd(2)#1 0 1 0 11 1 0 0 AbCc(2)"
 D ^VEXAMINE
 ;
END W !!,"End of 97 --- V3NEWP",!
 K  Q
 ;
NEWP1 ;
 N:$D(B)=0
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;000/
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
NEWP2 ;
 N:$d(D) B
 N:$d(A) A,D
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;011/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
