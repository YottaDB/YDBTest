V3TEXT3 ;IW-KO-YS-TS,V3TEXT,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"20---V3TEXT3: $TEXT function -3-"
 ;
 W !!,"Existence of specified entryref",!
 ;
1 S ^ABSN="30287",^ITEM="III-287  Specified routinename does not exist"
 S ^NEXT="2^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(^V3TEXTZ)
 S ^VCORR="" D ^VEXAMINE
 ;
2 S ^ABSN="30288",^ITEM="III-288  Specified label does not exist"
 S ^NEXT="3^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(ZZZZ^V3TEXTA)
 S ^VCORR="" D ^VEXAMINE
 ;
3 S ^ABSN="30289",^ITEM="III-289  intexpr has large value beyond eor"
 S ^NEXT="4^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$TEXT(A+894^V3TEXTA)
 S ^VCORR="" D ^VEXAMINE
 ;
4 S ^ABSN="30290",^ITEM="III-290  Specified label does not exist and intexpr is too large"
 S ^NEXT="5^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(ZBD00+9577^V3TEXTA)
 S ^VCORR="" D ^VEXAMINE
 ;
5 S ^ABSN="30291",^ITEM="III-291  Specified routinename does not exist and specified label does not exist"
 S ^NEXT="6^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(AZFF00+099999^V3TEXTZ)
 S ^VCORR="" D ^VEXAMINE
 ;
6 S ^ABSN="30292",^ITEM="III-292  Specified routinename does not exist, specified label does not exist, and intexpr is too large"
 S ^NEXT="7^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(AZFF00+099999^V3TEXTZ)
 S ^VCORR="" D ^VEXAMINE
 ;
 W !!,"Examination of values returned",!
 ;
7 S ^ABSN="30293",^ITEM="III-293  line has 255 characters"
 S ^NEXT="8^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(ABC^V3TEXTA)
 S N="0123456789 ",^VCORR="ABC S A=123 ;" F I=1:1:22 S ^VCORR=^VCORR_N
 D ^VEXAMINE
 ;
8 S ^ABSN="30294",^ITEM="III-294  multiple SPs exist between commands"
 S ^NEXT="9^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(ZZ0Z+5^V3TEXTA)
 S ^VCORR=" S A=5            S A=6     ;COMMNET" D ^VEXAMINE
 ;
9 S ^ABSN="30295",^ITEM="III-295  linebody contsins "" characters"
 S ^NEXT="10^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(A+10^V3TEXTA)
 S ^VCORR=" S A=""DATA""   S B(""B"")=""HELLO """" HELLO""" D ^VEXAMINE
 ;
10 S ^ABSN="30296",^ITEM="III-296  linebody consists of "";"" and eol"
 S ^NEXT="11^V3TEXT3,V3FOR^VV3" D ^V3PRESET
 S ^VCOMP=$T(ABC+1^V3TEXTA)
 S ^VCORR=" ;COMMENT  ;; COMMNET" D ^VEXAMINE
 ;
11 S ^ABSN="30297",^ITEM="II,III-297  ls has multi spaces"
 S ^NEXT="V3FOR^VV3" D ^V3PRESET
 ;(title corrected in V7.4;16/9/89)
 S ^VCOMP="" S ^VCOMP=$t(T95)_"*"_$TEXT(T95+1)
 S ^VCORR="T95       S A=1   ;$TEXT*                   S B=2   ;$TEXT+1"
 D ^VEXAMINE
 ;
END W !!,"End of 20 --- V3TEXT3",!
 K  Q
 ;
T95       S A=1   ;$TEXT
                   S B=2   ;$TEXT+1
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
