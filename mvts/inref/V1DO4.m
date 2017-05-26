V1DO4 ;IW-KO-TS,V1DO,MVTS V9.10;15/6/96;DO COMMAND (LOCAL BRANCHING) -4-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 ;
 W !!,"131---V1DO4: DO command (local branching) -4-"
 W !!,"DO label+intexpr",!
 G 240
 S V=V_"AAA " Q  ;V1DO4+6
 S V=V_"BBB " Q
 S V=V_"CCC " Q
00000000 S V=V_"00000000 " Q
240 W !,"I-240  intexpr is positive integer"
 S ^ABSN="11657",^ITEM="I-240  intexpr is positive integer",^NEXT="241^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 DO 1+1
 S ^VCOMP=V,^VCORR="01 " D ^VEXAMINE
 ;
241 W !,"I-241  intexpr is zero"
 S ^ABSN="11658",^ITEM="I-241  intexpr is zero",^NEXT="242^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D 00000000+0 S ^VCOMP=V,^VCORR="00000000 " D ^VEXAMINE
 ;
242 W !,"I-242  intexpr is non-integer numlit"
 S ^ABSN="11659",^ITEM="I-242  intexpr is non-integer numlit",^NEXT="243^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D 012+01.99999
 S ^VCOMP=V,^VCORR="ZXY987A0 " D ^VEXAMINE
 ;
243 W !,"I-243  intexpr is a function"
 S ^ABSN="11660",^ITEM="I-243  intexpr is a function",^NEXT="244^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D %2345678+$L(0.23000)
 S ^VCOMP=V,^VCORR="%A1 " D ^VEXAMINE
 ;
244 W !,"I-244  intexpr is a gvn"
 S ^ABSN="11661",^ITEM="I-244  intexpr is a gvn",^NEXT="245^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 S ^V1DO4=7 D V1DO4+^V1DO4
 S ^VCOMP=V,^VCORR="BBB " D ^VEXAMINE
 ;
245 W !,"I-245  intexpr contains binary operators"
2451 S ^ABSN="11662",^ITEM="I-245.1  + operator",^NEXT="2452^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D 12+-15+"17A"
 S ^VCOMP=V,^VCORR="100 " D ^VEXAMINE
 ;
2452 S ^ABSN="11663",^ITEM="I-245.2  _ operator",^NEXT="2453^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 DO IF+("0"_2)
 S ^VCOMP=V,^VCORR="Z012A " D ^VEXAMINE
 ;
2453 S ^ABSN="11664",^ITEM="I-245.3  Combination binary operators",^NEXT="246^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 S A=1 DO V1DO4+A+A*2+A+A+A+A+A+A+A+A+A+A-A-A-A-"1A"=10+8-1
 S ^VCOMP=V,^VCORR="CCC " D ^VEXAMINE
 ;
246 W !,"I-246  intexpr contains unary operators"
 S ^ABSN="11665",^ITEM="I-246  intexpr contains unary operators",^NEXT="247^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D 12+++-"-.037E+2"
 S ^VCOMP=V,^VCORR="IF " D ^VEXAMINE
 ;
247 W !,"I-247  intexpr contains gvn as expratom"
 S ^ABSN="11666",^ITEM="I-247  intexpr contains gvn as expratom",^NEXT="832^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 S ^V1A(2)=9765,^V1A(3)=9733
 D %0A1B2C3+^V1A(2)-^(3)/10
 S ^VCOMP=V,^VCORR="10 " D ^VEXAMINE
 ;
832 W !,"I-832  Argument list label without postcondition"
 S ^ABSN="11667",^ITEM="I-832  Argument list label without postcondition",^NEXT="833^V1DO4,V1CALL^VV1" D ^V1PRESET
 S V=""
 D %,%0A1B2C3,DO,012
 S ^VCOMP=V,^VCORR="% %0A1B2C3 DO 012 " D ^VEXAMINE
 ;
833 W !,"I-833  Argument list label+intexpr without postcondition"
 S ^ABSN="11668",^ITEM="I-833  Argument list label+intexpr without postcondition",^NEXT="V1CALL^VV1" D ^V1PRESET
 S V=""
 S ^V1A(2)=9765,^V1A(3)=9733
 D %0A1B2C3+^V1A(2)-^(3)/10,%2345678+$L(0.23000),Z,1+1
 S ^VCOMP=V,^VCORR="10 %A1 Z 01 " D ^VEXAMINE
 ;
END W !!,"End of 131---V1DO4",!
 K  K ^V1DO4,^V1A Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
012 S V=V_"012 " QUIT
 S V=V_"ZXY987A0 " Q
Z S V=V_"Z " Q
% S V=V_"% " Q
%2345678 S V=V_"%2345678 " Q
 S V=V_"%A1B2C3D " Q
 S V=V_"Q " Q
 S V=V_"%A1 " Q
DO S V=V_"DO "
 QUIT
12 S V=V_"12 " Q
 S V=V_"%A " Q
 S V=V_"100 " Q
IF S V=V_"IF " Q
 S V=V_"%0 " Q
 S V=V_"Z012A " Q
ABCDEFGH S V=V_"ABCDEFGH " Q
0 S V=V_"0 " Q
 QUIT
1 S V=V_"1 " Q
 S V=V_"01 " QUIT
%0A1B2C3 S V=V_"%0A1B2C3 " Q
 S V=V_"%90 " Q
 S V=V_"0012 " Q
 S V=V_"10 " Q
