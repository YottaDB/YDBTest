V2FN1 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"8---V2FN1: Functions extended ($D,$E,$F,$J,$L,$P,$T) -1-",!
 W !,"$DATA(glvn)",!
69 W !,"II-69  Effect of local variable descendant KILL"
 S ^ABSN="20069",^ITEM="II-69  Effect of local variable descendant KILL",^NEXT="70^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP=""
 K VV S VV(1)=0,VV(1,2)=0 k VV(1,2) S ^VCOMP=$d(VV(1)) S ^VCORR=1 D ^VEXAMINE
 ;
70 W !,"II-70  Effect of global variable descendant KILL"
 S ^ABSN="20070",^ITEM="II-70  Effect of global variable descendant KILL",^NEXT="71^V2FN1,V2FN2^VV2" D ^V2PRESET
 S VCOMP=""
 K ^VV S ^VV(1)=0,^(1,2)=0 K ^(2) S VCOMP=$D(^VV(1))_" "_$D(^VV(1,2))
 S ^VCOMP=VCOMP,^VCORR="1 0" D ^VEXAMINE
 ;
71 W !!,"$EXTRACT(expr)",!
 W !,"II-71  expr is a strlit"
 S ^ABSN="20071",^ITEM="II-71  expr is a strlit",^NEXT="72^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$e("ABC"),^VCORR="A" D ^VEXAMINE
 ;
72 W !,"II-72  expr is 255 characters"
 S ^ABSN="20072",^ITEM="II-72  expr is 255 characters",^NEXT="73^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",X="B" F I=1:1:254 S X=X_"A"
 S ^VCOMP=$extract(X),^VCORR="B" D ^VEXAMINE
 ;
73 W !,"II-73  expr is an empty string"
 S ^ABSN="20073",^ITEM="II-73  expr is an empty string",^NEXT="74^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="ERROR",^VCOMP=$e(""),^VCORR="" D ^VEXAMINE
 ;
74 W !,"II-74  expr is a numeric literal"
 S ^ABSN="20074",^ITEM="II-74  expr is a numeric literal",^NEXT="75^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="123" S ^VCOMP=$E(-123.3E-2)_$E(000.34)_$E(0.23E5)_$e(00076.450)
 S ^VCORR="-.27" D ^VEXAMINE
 ;
75 W !!,"$FIND(expr1,expr2,intexpr3)",!
 W !,"II-75  intexpr3<0 and expr1 is a strlit"
 S ^ABSN="20075",^ITEM="II-75  intexpr3<0 and expr1 is a strlit",^NEXT="76^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$f("ABC","A",-1),^VCORR="2" D ^VEXAMINE
 ;
76 W !,"II-76  intexpr3<0 and expr1 is a variable"
 S ^ABSN="20076",^ITEM="II-76  intexpr3<0 and expr1 is a variable",^NEXT="77^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",X="ABC8",Y="B",^VCOMP=$Find(X,Y,123-557),^VCORR=3 D ^VEXAMINE
 ;
77 W !!,"$JUSTIFY(numexpr1,intexpr2,intexpr3)",!
 W !,"II-77  0<numexpr1<1"
 S ^ABSN="20077",^ITEM="II-77  0<numexpr1<1",^NEXT="78^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$justify(000.123,5,2)_$j(789E-3,4,1)
 S X=2,Y=3 S ^VCOMP=^VCOMP_$J(X/Y,X,Y) S ^VCORR=" 0.12 0.80.667" D ^VEXAMINE
 ;
78 W !,"II-78  -1<numexpr1<0"
 S ^ABSN="20078",^ITEM="II-78  -1<numexpr1<0",^NEXT="91^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$justify(-0.123,6,2)_$j(-1+.241,5,1)
 S ^VCORR=" -0.12 -0.8" D ^VEXAMINE
 ;
91 W !!,"$PIECE(expr1,expr2)",!
 W !,"II-91  expr1 and expr2 are strlits"
 S ^ABSN="20079",^ITEM="II-91  expr1 and expr2 are strlits",^NEXT="92^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP=""
 S ^VCOMP=$PIECE("ABC","B")_"*"_$Piece("ABC","D")_"*"_$p("ABC","BC")
 S ^VCORR="A*ABC*A" D ^VEXAMINE
 ;
92 W !,"II-92  expr2 is an empty string"
 S ^ABSN="20080",^ITEM="II-92  expr2 is an empty string",^NEXT="93^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="DDDD",^VCOMP=$P("ABC",""),^VCORR="" D ^VEXAMINE
 ;
93 W !,"II-93  expr1 is an empty string"
 S ^ABSN="20081",^ITEM="II-93  expr1 is an empty string",^NEXT="94^V2FN1,V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="AD",^VCOMP=$P("","AB"),^VCORR="" D ^VEXAMINE
 ;
94 W !,"II-94  expr1 and expr2 are variables"
 S ^ABSN="20082",^ITEM="II-94  expr1 and expr2 are variables",^NEXT="V2FN2^VV2" D ^V2PRESET
 S ^VCOMP="",X="AAAA",Y="AAAAA",Z="AAA",^VCOMP=$P(X,Y)_"*"_$P(X,Z)_"*"
 S X="C"_$C(7)_"B"_$C(7)_"A",^VCOMP=^VCOMP_$P(X,$C(7))_"*"
 S X=0000123456E-3,Y=".",X(1)=976.565,Y(1.0)=6.56,^VCOMP=^VCOMP_$P(X,Y)_"*"_$P(X(1),Y(1))
 S ^VCORR="AAAA**C*123*97" D ^VEXAMINE
 ;
END W !!,"End of 8---V2FN1",!
 K  K ^VV Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
