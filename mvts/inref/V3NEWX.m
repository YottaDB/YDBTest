V3NEWX ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"98---V3NEWX: NEW -28-"
 W !!,"NEW command within XECUTE command"
 ;
55 S ^ABSN="30962",^ITEM="III-0962  NEW B,C"
 S ^NEXT="56^V3NEWX,V3NEWDO1^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S A="A",A(2)="A(2)",B="B",B(2)="B(2)",C="C",C(2)="C(2)"
 S ^VCOMP=""
 D NEWX1
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCORR="11 1 0 0 0 0 #11 1 0 0 0 0 0 0 1A(2)#111111/11 1 11 1 11 1 11 1 aa(2)bB(2)Cc(2)dd(2)#11 1 11 1 11 1 11 1 aa(2)bB(2)Cc(2)dd(2)"
 D ^VEXAMINE
 ;
56 S ^ABSN="30963",^ITEM="III-0963  NEW (B,C)"
 S ^NEXT="^V3NEWDO1,V3NEWDO2^V3NEW,V3ALDO^VV3" D ^V3PRESET K
 S ^VCOMP=""
 S A="A",B="B",C="C"
 D NEWX2                                  ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;A
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;BB(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;CC
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCORR="1 0 1 0 1 0 #1 0 1 0 1 0 0 0 1BC#11111/11 1 11 1 11 1 11 1 aa(2)bBB(2)CCc(2)dd(2)#11 1 11 1 11 1 11 1 aa(2)bBB(2)CCc(2)dd(2)"
 D ^VEXAMINE
 ;
END W !!,"End of 98 --- V3NEWX",!
 K  Q
 ;
NEWX1 ;
 S A="NEW B,C S A=1 S ^VCOMP=^VCOMP_$D(A)_"" ""_$D(A(2))_"" ""_$D(B)_"" ""_$D(B(2))_"" ""_$D(C)_"" ""_$D(C(2))_"" #"" D ^V3NEWXE1" X A ;11 1 0 0 0 0 #11 1 0 0 0 0 0 0 #
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;111111/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;B(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;C
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
NEWX2 ;
 S A="NEW (B,C) S A=1 S ^VCOMP=^VCOMP_$D(A)_"" ""_$D(A(2))_"" ""_$D(B)_"" ""_$D(B(2))_"" ""_$D(C)_"" ""_$D(C(2))_"" #"" D NEWXE2" X A ;1 0 1 0 1 0 #
 S ^VCOMP=^VCOMP_$D(A)_$D(B)_$D(C)_"/"    ;11111/
 S A="a",A(2)="a(2)",B="b",C(2)="c(2)",D="d",D(2)="d(2)"
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;11 1 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;11 1 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;a
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;a(2)
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;b
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;BB(2)
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;CC
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;c(2)
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;d
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;d(2)
 S ^VCOMP=^VCOMP_"#"                      ;#
 QUIT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
NEWXE2 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;1 0 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 I $D(A)#10=1    S ^VCOMP=^VCOMP_A        ;1
 I $D(A(2))#10=1 S ^VCOMP=^VCOMP_A(2)     ;
 I $D(B)#10=1    S ^VCOMP=^VCOMP_B        ;B
 I $D(B(2))#10=1 S ^VCOMP=^VCOMP_B(2)     ;
 I $D(C)#10=1    S ^VCOMP=^VCOMP_C        ;
 I $D(C(2))#10=1 S ^VCOMP=^VCOMP_C(2)     ;C
 I $D(D)#10=1    S ^VCOMP=^VCOMP_D        ;
 I $D(D(2))#10=1 S ^VCOMP=^VCOMP_D(2)     ;
 S A="AA",A(2)="AA(2)",B="BB",B(2)="BB(2)",C="CC",C(2)="CC(2)"
 S ^VCOMP=^VCOMP_"#"                      ;#
