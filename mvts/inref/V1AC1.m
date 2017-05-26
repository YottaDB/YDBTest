V1AC1 ;IW-YS-TS,V1AC,MVTS V9.10;15/6/96;$ASCII AND $CHAR FUNCTIONS -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"104---V1AC1: $CHAR and $CHAR functions -1-",!
 W !,"$CHAR(L intexpr)",!
1 W !,"I-1  intexpr is checked for 32-126"
 S ^ABSN="11425",^ITEM="I-1  intexpr is checked for 32-126",^NEXT="2^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S VCOMP=""
 F I=32:1:126 SET VCOMP=VCOMP_$CHAR(I)
 S ^VCOMP=VCOMP,^VCORR=" !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" D ^VEXAMINE
 ;
2 W !,"I-2  L intexpr is checked for 32-126"
 S ^ABSN="11426",^ITEM="I-2  L intexpr is checked for 32-126",^NEXT="3^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="" F I=32:8:112 S ^VCOMP=^VCOMP_$C(I,I+1,I+2,I+3,I+4,I+5,I+6,I+7)
 S I=120,^VCOMP=^VCOMP_$C(I,I+1,I+2,I+3,I+4,I+5,I+6)
 S ^VCORR=" !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~" D ^VEXAMINE
 ;
3 W !,"I-3  Integer interpretation of intexpr, while intexpr is string literal"
 S ^ABSN="11427",^ITEM="I-3  Integer interpretation of intexpr, while intexpr is string literal",^NEXT="4^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S VCOMP=$C("65A","+66ABC",-"-67.3G1","68000E-3","71+10")
 S ^VCOMP=VCOMP,^VCORR="ABCDG" D ^VEXAMINE
 ;
4 W !,"I-4  Integer interpretation of intexpr, while intexpr is numeric literal"
 S ^ABSN="11428",^ITEM="I-4  Integer interpretation of intexpr, while intexpr is numeric literal",^NEXT="5^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$CHAR(0.0069E+4,35.2*2.001),^VCORR="EF" D ^VEXAMINE
 ;
5 W !,"I-5  Integer interpretation of intexpr, while intexpr contains binaryop"
 S ^ABSN="11429",^ITEM="I-5  Integer interpretation of intexpr, while intexpr contains binaryop",^NEXT="6^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$C(15+15+2,+"66ABC"--2-3,"6"_"6"),^VCORR=" AB" D ^VEXAMINE
 ;
6 W !,"I-6  intexpr<0"
 S ^ABSN="11430",^ITEM="I-6  intexpr<0",^NEXT="7^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 K ^VCOMP S ^VCOMP=$C(-1),A=-48
 S ^VCOMP=^VCOMP_$C(-1.00002,-100,-255,-78.9,"-66",A),^VCORR="" D ^VEXAMINE
 ;
7 W !,"I-7  The difference between $CHAR(0) and empty string"
71 S ^ABSN="11431",^ITEM="I-7.1  Empty string",^NEXT="72^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S X="",VCOMP="" S X=$C(0) ;test change in V7.4;16/9/89
 I X="" S VCOMP="EMPTY"
 I X'="" S VCOMP="OK"
 S ^VCOMP=VCOMP,^VCORR="OK" D ^VEXAMINE
72 S ^ABSN="11432",^ITEM="I-7.2  $LENGTH",^NEXT="73^V1AC1,V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S X="" S X=$C(0)
 S ^VCOMP=$L(X),^VCORR=1 D ^VEXAMINE
73 S ^ABSN="11433",^ITEM="I-7.3  Value of $A",^NEXT="V1AC2^V1AC,V1LVN^VV1" D ^V1PRESET
 S X="" S X=$C(0)
 S ^VCOMP=$A(X),^VCORR=0 D ^VEXAMINE
 ;
END W !!,"End of 104---V1AC1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
