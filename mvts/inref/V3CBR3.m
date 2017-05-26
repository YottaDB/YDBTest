V3CBR3 ;IW-KO-YS-TS,V3CBR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
1 W !!,"142---V3CBR3: call by reference -3-",!
 S ^ABSN="31101",^ITEM="III-1101  selective KILL command and SET command"
 S ^NEXT="2^V3CBR3,V3CBR4^V3CBR,END^VV3" D ^V3PRESET
 S X="X",Y="Y"
 S ^VCOMP="" d  S ^VCOMP=^VCOMP_"C"
 . S ^VCOMP=^VCOMP_"A" d A(.X,.Y) S ^VCOMP=^VCOMP_"B"
 D CHK
 S ^VCORR="A/1X 1Y 1X 1Y|/1a 1b 1a 1b|BC1a 1b 0 0|" D ^VEXAMINE
 ;
2 S ^ABSN="31102",^ITEM="III-1102  KILL all command and SET command"
 S ^NEXT="3^V3CBR3,V3CBR4^V3CBR,END^VV3" D ^V3PRESET
 S X="X",Y="Y"
 S ^VCOMP="" d  S ^VCOMP=^VCOMP_"C"
 . S ^VCOMP=^VCOMP_"A" d B(.X,.Y) S ^VCOMP=^VCOMP_"B"
 D CHK
 S ^VCORR="A/1X 1Y 1X 1Y|/1a 1b 1a 1b|BC1a 1b 0 0|" D ^VEXAMINE
 ;
3 S ^ABSN="31103",^ITEM="III-1103  exclusive KILL command and SET command"
 S ^NEXT="V3CBR4^V3CBR,END^VV3" D ^V3PRESET
 S X="X",Y="Y"
 S ^VCOMP="" d  S ^VCOMP=^VCOMP_"C"
 . S ^VCOMP=^VCOMP_"A" d C(.X,.Y) S ^VCOMP=^VCOMP_"B"
 D CHK
 S ^VCORR="A/1X 1Y 1X 1Y|/1a 1b 1a 1b|BC1a 1b 0 0|" D ^VEXAMINE
END W !!,"End of 142 --- V3CBR3",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
A(A,B) S ^VCOMP=^VCOMP_"/" D CHK
 K A
 s X="x",B="b",A="a"
 S ^VCOMP=^VCOMP_"/" D CHK
 Q
 ;
B(A,B) S ^VCOMP=^VCOMP_"/" D CHK
 K
 s X="x",B="b",A="a"
 S ^VCOMP=^VCOMP_"/" D CHK
 Q
 ;
C(A,B) S ^VCOMP=^VCOMP_"/" D CHK
 K (A)
 s X="x",B="b",A="a"
 S ^VCOMP=^VCOMP_"/" D CHK
 Q
CHK ;
 S ^VCOMP=^VCOMP_$D(X)      I $D(X)#10=1 S ^VCOMP=^VCOMP_X
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(Y)      I $D(Y)#10=1 S ^VCOMP=^VCOMP_Y
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(A)      I $D(A)#10=1 S ^VCOMP=^VCOMP_A
 S ^VCOMP=^VCOMP_" "
 S ^VCOMP=^VCOMP_$D(B)      I $D(B)#10=1 S ^VCOMP=^VCOMP_B
 S ^VCOMP=^VCOMP_"|"
 Q
