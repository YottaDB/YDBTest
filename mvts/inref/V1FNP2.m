V1FNP2 ;IW-YS-TS,V1FN,MVTS V9.10;15/6/96;FUNCTION $PIECE -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"102---V1FNP2: $PIECE function -2-",!
325 W !,"I-325  expr1 is non-intexpr numeric literal"
 S ^ABSN="11404",^ITEM="I-325  expr1 is non-intexpr numeric literal",^NEXT="326^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP=$P(123.5,3,1) S ^VCORR=12 D ^VEXAMINE
 ;
326 W !,"I-326  expr1 is an empty string"
 S ^ABSN="11405",^ITEM="I-326  expr1 is an empty string",^NEXT="327^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$P("","B",2) S ^VCORR="" D ^VEXAMINE
 ;
327 W !,"I-327  expr2 is an empty string"
 S ^ABSN="11406",^ITEM="I-327  expr2 is an empty string",^NEXT="328^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$P("ABCBD","",2) S ^VCORR="" D ^VEXAMINE
 ;
328 W !,"I-328  expr1 are expr2 are empty strings"
 S ^ABSN="11407",^ITEM="I-328  expr1 are expr2 are empty strings",^NEXT="329^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$P("","",2) S ^VCORR="" D ^VEXAMINE
 ;
329 W !,"I-329  expr2 is numeric literal"
 S ^ABSN="11408",^ITEM="I-329  expr2 is numeric literal",^NEXT="330^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP="123" S ^VCOMP=$P("12.34.56.78.89.90",-000.1,3.1) S ^VCORR="" D ^VEXAMINE
 ;
330 W !,"I-330  expr2 contains operators"
3301 S ^ABSN="11409",^ITEM="I-330.1  Concatenation operator",^NEXT="3302^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP="123",^VCOMP=$P("ABCBCDBC","B"_"C",2),^VCORR="" D ^VEXAMINE
3302 S ^ABSN="11410",^ITEM="I-330.2  Another concatenation operator",^NEXT="3303^V1FNP2,V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP=$P("AB CBbcBBC    BC DBC","B"_"C",2),^VCORR="    " D ^VEXAMINE
3303 S ^ABSN="11411",^ITEM="I-330.3  + binary operators",^NEXT="V1FNP3^V1FN,V1AC^VV1" D ^V1PRESET
 S ^VCOMP=$P(9139191,80+9+2,2.2),^VCORR="3" D ^VEXAMINE
 ;
END W !!,"End of 102---V1FNP2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
