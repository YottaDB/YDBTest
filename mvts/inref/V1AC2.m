V1AC2 ;IW-YS-TS,V1AC,MVTS V9.10;15/6/96;$ASCII AND $CHAR FUNCTIONS -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"105---V1AC2: $ASCII and $CHAR functions -2-",!
 W !,"$ASCII(expr)",!
8 W !,"I-8  expr is string literal, and $L(expr)=0  i.e. expr is empty string"
 S ^ABSN="11434",^ITEM="I-8  expr is string literal, and $L(expr)=0  i.e. expr is empty string",^NEXT="9^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="" S ^VCOMP=$A(""),^VCORR="-1" D ^VEXAMINE
 ;
9 W !,"I-9  expr is string literal, and $L(expr)=1"
 S ^ABSN="11435",^ITEM="I-9  expr is string literal, and $L(expr)=1",^NEXT="10^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S VCOMP=""
 S VCOMP=$ASCII(" ")_$A("!")_$A("""")_$A("#")_$A("$")_$A("%")_$A("&")_$A("'")
 S VCOMP=VCOMP_$A("(")_$A(")")_$A("*")_$A("+")_$A(",")_$A("-")_$A(".")
 S VCOMP=VCOMP_$A("/")_$A("0")_$A("1")_$A("2")_$A("3")_$A("4")_$A("5")_$A("6")
 S VCOMP=VCOMP_$A("7")_$A("8")_$A("9")_$A(":")_$A(";")_$A("<")_$A("=")_$A(">")_$A("?")_$A("@")
 S ^VCOMP=VCOMP,^VCORR="323334353637383940414243444546474849505152535455565758596061626364"
 D ^VEXAMINE
 ;
10 W !,"I-10  expr is string literal, and $L(expr)>0"
 S ^ABSN="11436",^ITEM="I-10  expr is string literal, and $L(expr)>0",^NEXT="11^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S X="*|^=09876",^VCOMP=$A(X),^VCORR=42 D ^VEXAMINE
 ;
11 W !,"I-11  expr is numeric literal, and $L(expr)=1  i.e. expr is a digit"
 S ^ABSN="11437",^ITEM="I-11  expr is numeric literal, and $L(expr)=1  i.e. expr is a digit",^NEXT="12^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(02),^VCORR=50 D ^VEXAMINE
 ;
12 W !,"I-12  expr is numeric literal, and $L(expr)>1,expr<0"
 S ^ABSN="11438",^ITEM="I-12  expr is numeric literal, and $L(expr)>1,expr<0",^NEXT="13^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(-0.30) S ^VCORR=45 D ^VEXAMINE
 ;
13 W !,"I-13  expr is numeric literal, and $L(expr)>1,expr<=0"
 S ^ABSN="11439",^ITEM="I-13  expr is numeric literal, and $L(expr)>1,expr<=0",^NEXT="14^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP=$A(.00E3),^VCORR=48 D ^VEXAMINE
 ;
14 W !,"I-14  expr is $CHAR corresponding to ASCII code 0-127"
141 S ^ABSN="11440",^ITEM="I-14.1  0-31",^NEXT="142^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="" F I=0:1:31 S ^VCOMP=^VCOMP_$A($C(I))
 S ^VCORR="012345678910111213141516171819202122232425262728293031" D ^VEXAMINE
 ;
142 S ^ABSN="11441",^ITEM="I-14.2  32-94",^NEXT="143^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S VCOMP="" F I=32:1:94 S VCOMP=VCOMP_$A($C(I))
 S ^VCOMP=VCOMP,^VCORR="323334353637383940414243444546474849505152535455565758596061626364656667686970717273747576777879808182838485868788899091929394" D ^VEXAMINE
 ;
143 S ^ABSN="11442",^ITEM="I-14.3  95-127",^NEXT="144^V1AC2,V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S VCOMP="" F I=95:1:127 S VCOMP=VCOMP_$A($C(I))
 S ^VCOMP=VCOMP,^VCORR="9596979899100101102103104105106107108109110111112113114115116117118119120121122123124125126127" D ^VEXAMINE
 ;
144 S ^ABSN="11443",^ITEM="I-14.4  expr is a lvn",^NEXT="V1AC3^V1AC,V1LVN^VV1" D ^V1PRESET
 S ^VCOMP="",X=1,Y=$C($A(X),$A(X,2))
 S ^VCOMP=$L(Y)_" "_Y S ^VCORR="1 1" D ^VEXAMINE
 ;
END W !!,"End of 105---V1AC2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
