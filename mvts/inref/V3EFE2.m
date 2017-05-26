V3EFE2(X,Y) ;IW-KO-YS-TS,V3EF,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
A0(A,B,C,D,E,F,G) ;
 S Q=""
 S Q=Q_$D(A)      I $D(A)#10=1 S Q=Q_A
 S Q=Q_" "
 S Q=Q_$D(A(1))   I $D(A(1))#10=1 S Q=Q_A(1)
 S Q=Q_" "
 S Q=Q_$D(B)      I $D(B)#10=1 S Q=Q_B
 S Q=Q_" "
 S Q=Q_$D(B(2,3)) I $D(B(2,3))#10=1 S Q=Q_B(2,3)
 S Q=Q_" "
 S Q=Q_$D(C)      I $D(C)#10=1 S Q=Q_C
 S Q=Q_" "
 S Q=Q_$D(C("A")) I $D(C("A"))#10=1 S Q=Q_C("A")
 S Q=Q_" "
 S Q=Q_$D(D)      I $D(D)#10=1 S Q=Q_D
 S Q=Q_" "
 S Q=Q_$D(D(1,2,3)) I $D(D(1,2,3))#10=1 S Q=Q_D(1,2,3)
 S Q=Q_" "
 S Q=Q_$D(E)      I $D(E)#10=1 S Q=Q_E
 S Q=Q_" "
 S Q=Q_$D(F)      I $D(F)#10=1 S Q=Q_F
 S Q=Q_" "
 S Q=Q_$D(G)      I $D(G)#10=1 S Q=Q_G
 S Q=Q_"/"
 S Q=Q_$D(X)      I $D(X)#10=1 S Q=Q_X
 S Q=Q_" "
 S Q=Q_$D(X(1))   I $D(X(1))#10=1 S Q=Q_X(1)
 S Q=Q_" "
 S Q=Q_$D(Y)      I $D(Y)#10=1 S Q=Q_Y
 S Q=Q_" "
 S Q=Q_$D(Y(2,3)) I $D(Y(2,3))#10=1 S Q=Q_Y(2,3)
 S Q=Q_" "
 S Q=Q_$D(Z)      I $D(Z)#10=1 S Q=Q_Z
 S Q=Q_" "
 S Q=Q_$D(Z("A")) I $D(Z("A"))#10=1 S Q=Q_Z("A")
 S Q=Q_" "
 S Q=Q_$D(W)      I $D(W)#10=1 S Q=Q_W
 S Q=Q_" "
 S Q=Q_$D(W(1,2,3)) I $D(W(1,2,3))#10=1 S Q=Q_W(1,2,3)
 S Q=Q_" "
 S Q=Q_$D(P)      I $D(P)#10=1 S Q=Q_P
 S Q=Q_"/"
 Q Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
