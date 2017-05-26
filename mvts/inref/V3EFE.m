V3EFE(X,Y) ;IW-KO-YS-TS,V3EF,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 N I,A
 S A="" F I=1:1:Y S A=A_X
 Q A
 ;
AB(X,Y,Z) ;
 S ^VCOMP=^VCOMP_$d(X) I $D(X)#10=1 S ^VCOMP=^VCOMP_X
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$d(Y) I $D(Y)#10=1 S ^VCOMP=^VCOMP_Y
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$d(Z) I $D(Z)#10=1 S ^VCOMP=^VCOMP_Z
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$d(W) I $D(W)#10=1 S ^VCOMP=^VCOMP_W
 S ^VCOMP=^VCOMP_" "
 K Y
 S X="x",Y="y",W="w"
 Q "/"_X_Y_W_" "
A0(A,B,C,D,E,F,G) ;
 S ^VCOMP=^VCOMP_$D(A)      I $D(A)#10=1 S ^VCOMP=^VCOMP_A
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(A(1))   I $D(A(1))#10=1 S ^VCOMP=^VCOMP_A(1)
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(B)      I $D(B)#10=1 S ^VCOMP=^VCOMP_B
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(B(2,3)) I $D(B(2,3))#10=1 S ^VCOMP=^VCOMP_B(2,3)
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(C)      I $D(C)#10=1 S ^VCOMP=^VCOMP_C
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(C("A")) I $D(C("A"))#10=1 S ^VCOMP=^VCOMP_C("A")
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(D)      I $D(D)#10=1 S ^VCOMP=^VCOMP_D
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(D(1,2,3)) I $D(D(1,2,3))#10=1 S ^VCOMP=^VCOMP_D(1,2,3)
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(E)      I $D(E)#10=1 S ^VCOMP=^VCOMP_E
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(F)      I $D(F)#10=1 S ^VCOMP=^VCOMP_F
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(G)      I $D(G)#10=1 S ^VCOMP=^VCOMP_G
 S ^VCOMP=^VCOMP_"/"
 Q $$ABC($g(A))
 ;
ABC(QQ) ;
 S QQ="Q" Q QQ_$g(A)_"/"
 ;
T(X,Y,Z) ;
 s T=""
 S T=T_$d(X) I $D(X)#10=1 S T=T_X
 S T=T_" "
 S T=T_$d(Y) I $D(Y)#10=1 S T=T_Y
 S T=T_" "
 S T=T_$d(Z) I $D(Z)#10=1 S T=T_Z
 S T=T_" "
 S T=T_$d(W) I $D(W)#10=1 S T=T_W
 S T=T_" "
 I 1 K Y
 S X="x",Y="y",W="w"
 Q T_"/"_X_Y_W_" "_$T_"/"
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
