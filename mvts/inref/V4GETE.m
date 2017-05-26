V4GETE(A,B,C) ;IW-KO-YS-TS,V4GET2,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 N X,Y,Z
 S A=A_"a",B=B_"b",C=C_"c"
 s Y=A_" "_B_" "_C
 K X,Z,A,B,C
 Q Y
 ;
ABC(A,B,C) ;
 n X
 S X=A_"/"_B_"/"
 s B=X q C
 ;
GETNAME() K VV,V Q "A(1)"
 ;
GETDATA() Q "##"
 q
GVN() N X
 S X="^VV(""ABC"")"
 Q X
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
