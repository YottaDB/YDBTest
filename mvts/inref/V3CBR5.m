V3CBR5 ;IW-KO-YS-TS,V3CBR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
1 W !!,"144---V3CBR5: call by reference -5-",!
 S ^ABSN="31107",^ITEM="III-1107  nesting 1"
 S ^NEXT="2^V3CBR5,END^VV3" D ^V3PRESET
 S ^VCOMP=""
 S X="X",B="B"
 D A(.X,B)
 D CHK
 S ^VCORR="1X 0 1X 1B/1x 0 1x 1b/1x2 0 1x 1b2/1x2 0 1x2 1b/1x2 0 0 1B/" D ^VEXAMINE
 ;
2 S ^ABSN="31108",^ITEM="III-1108  nesting 2"
 S ^NEXT="END^VV3" D ^V3PRESET
 S ^VCOMP=""
 S X="X",B="B"
 D C(.X)
 D CHK
 S ^VCORR="1X 0 1X 1B/1a 0 1a 1a/1a2 0 1a2 1b2/1a2 0 1a2 1b/1a2 0 0 1b/" D ^VEXAMINE
 ;
END W !!,"End of 144 --- V3CBR5",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
A(A,B) D CHK   S X="x",B="b"    D B(A,B)   D CHK Q
B(A,B) D CHK   S X="x2",B="b2"  D CHK Q
 ;
C(A) D CHK   S A="a",B="b"    D D(A)     D CHK Q
D(B) D CHK   S A="a2",B="b2"  D CHK Q
 ;
CHK ;
 S ^VCOMP=^VCOMP_$D(X)      I $D(X)#10=1 S ^VCOMP=^VCOMP_X
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(Y)      I $D(Y)#10=1 S ^VCOMP=^VCOMP_Y
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(A)      I $D(A)#10=1 S ^VCOMP=^VCOMP_A
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(B)      I $D(B)#10=1 S ^VCOMP=^VCOMP_B
 S ^VCOMP=^VCOMP_"/"
 Q
