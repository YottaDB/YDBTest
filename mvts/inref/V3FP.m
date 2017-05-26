V3FP ;IW-KO-YS-TS,VV3,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
1 W !!,"136---V3FP: Fundamental tests of parameter passing",!
 ;
 S ^ABSN="31075",^ITEM="III-1075  formal list"
 S ^NEXT="2^V3FP,V3DWP^VV3" D ^V3PRESET K  i 1
 S ^VCOMP="" D LABEL(1,2,3)
 S ^VCORR="1 2 3 " D ^VEXAMINE
 ;
2 S ^ABSN="31076",^ITEM="III-1076  call by value"
 S ^NEXT="3^V3FP,V3DWP^VV3" D ^V3PRESET K
 S ^VCOMP="" S A="A",X="X"
 D LABEL("ABC",A,X)
 S ^VCORR="ABC A X " D ^VEXAMINE
 ;
3 S ^ABSN="31077",^ITEM="III-1077  call by reference"
 S ^NEXT="4^V3FP,V3DWP^VV3" D ^V3PRESET K
 S ^VCOMP="" S A(2)="A2",B="B"
 D REF(.A,.123,.B)
 S ^VCORR="A2 .123 B/ " D ^VEXAMINE
 ;
4 S ^ABSN="31078",^ITEM="III-1078  QUIT with argument"
 S ^NEXT=",V3DWP^VV3" D ^V3PRESET K
 S ^VCOMP="",A="-5"
 S ^VCOMP=$$FUNC(2,.A)
 S ^VCORR="-10" D ^VEXAMINE
 ;
END W !!,"End of 136 --- V3FP",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
LABEL(X,Y,Z) ;
 S ^VCOMP=^VCOMP_X_" "_Y_" "_Z_" " Q
FUNC(X,Y) Q X*Y
REF(X,Y,Z,W) ;
 S ^VCOMP=^VCOMP_X(2)_" "_Y_" "_Z_"/"
 S ^VCOMP=^VCOMP_$G(W)_" "
