V1AC3 ;IW-YS-TS,V1AC,MVTS V9.10;15/6/96;$ASCII AND $CHAR FUNCTIONS -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"106---V1AC3: $ASCII and $CHAR functions -3-"
 ;
15 W !!,"$A(expr1,intexpr2)",!
 W !,"I-15  expr1 is string literal"
 S ^ABSN="11444",^ITEM="I-15  expr1 is string literal",^NEXT="16^V1AC3,V1LVN^VV1" D ^V1PRESET
 S VCOMP="" F I=1:1:30 S VCOMP=VCOMP_$A(">?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[",I)
 S ^VCOMP=VCOMP,^VCORR="626364656667686970717273747576777879808182838485868788899091" D ^VEXAMINE
 ;
16 W !,"I-16  expr1 is non-integer numeric literal, and greater than zero"
 S ^ABSN="11445",^ITEM="I-16  expr1 is non-integer numeric literal, and greater than zero",^NEXT="17^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(034.95165E2,00.04000E+2),^VCORR=53 D ^VEXAMINE
 ;
17 W !,"I-17  expr1 is non-integer numeric literal, and less than zero"
 S ^ABSN="11446",^ITEM="I-17  expr1 is non-integer numeric literal, and less than zero",^NEXT="18^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(-00.000034567000E+008,6000E-3),^VCORR=46 D ^VEXAMINE
 ;
18 W !,"I-18  expr1 is integer numeric literal, and greater than zero"
 S ^ABSN="11447",^ITEM="I-18  expr1 is integer numeric literal, and greater than zero",^NEXT="19^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(00000234650.0000,2+1),^VCORR="52" D ^VEXAMINE
 ;
19 W !,"I-19  expr1 is integer numeric literal, and less than zero"
 S ^ABSN="11448",^ITEM="I-19  expr1 is integer numeric literal, and less than zero",^NEXT="21^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="" S ^VCOMP=$A(-0059.34E3,04) S ^VCORR=51 D ^VEXAMINE
 ;
20 ;
21 W !,"I-20/21  intexpr2 is less than zero or greater than $L(expr1)"
201 S ^ABSN="11449",^ITEM="I-20/21.1  intexpr2 is less than zero",^NEXT="202^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="" S ^VCOMP=$A("Q",-2),^VCORR="-1" D ^VEXAMINE
202 S ^ABSN="11450",^ITEM="I-20/21.2  intexpr2 is greater than $L(expr1)",^NEXT="203^V1AC3,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(1,2),^VCORR="-1" D ^VEXAMINE
203 S ^ABSN="11451",^ITEM="I-20/21.3  expr1 is a strlit",^NEXT="204^V1AC3,V1LVN^VV1" D ^V1PRESET
 S VCOMP="" F I=-3:1:8 S VCOMP=VCOMP_$A("\]^_",I)
 S ^VCOMP=VCOMP,^VCORR="-1-1-1-192939495-1-1-1-1" D ^VEXAMINE
 ;
204 S ^ABSN="11452",^ITEM="I-20/21.4  expr1 is non-integer literal",^NEXT="V1LVN^VV1" D ^V1PRESET
 S VCOMP="" F I=-1:1:9 S VCOMP=VCOMP_$A(12345.6,I)
 S ^VCOMP=VCOMP,^VCORR="-1-149505152534654-1-1" D ^VEXAMINE
 ;
END W !!,"End of 106---V1AC3",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
