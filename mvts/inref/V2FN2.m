V2FN2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;FUNCTIONS EXTENDED ($D,$E,$F,$J,$L,$P,$T) -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"9---V2FN2: Functions extended ($D,$E,$F,$J,$L,$P,$T) -2-",!
 W !!,"$LENGTH(expr1,expr2)",!
79 W !,"II-79  expr1 and expr2 are string literals"
 S ^ABSN="20083",^ITEM="II-79  expr1 and expr2 are string literals",^NEXT="80^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$length("ABCBC","B")_$l("ABCBCABC","BC"),^VCORR=34 D ^VEXAMINE
 ;
80 W !,"II-80  expr2 is an empty string"
 S ^ABSN="20084",^ITEM="II-80  expr2 is an empty string",^NEXT="81^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$L("ABC","") S ^VCORR="0" D ^VEXAMINE
 ;
81 W !,"II-81  $L(expr1)<$L(expr2)"
 S ^ABSN="20085",^ITEM="II-81  $L(expr1)<$L(expr2)",^NEXT="82^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$L("A","ABC") S ^VCORR="1" D ^VEXAMINE
 ;
82 W !,"II-82  $L(expr1,expr2)=3"
 S ^ABSN="20086",^ITEM="II-82  $L(expr1,expr2)=3",^NEXT="83^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP=$L("AAAA","AA")_$l("0000000000","00000"),^VCORR="33" D ^VEXAMINE
 ;
83 W !,"II-83  $L(expr1,expr2)=2"
 S ^ABSN="20087",^ITEM="II-83  $L(expr1,expr2)=2",^NEXT="84^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP=$L("AAAA","AAA")_$L("0000000000","00000000"),^VCORR=22 D ^VEXAMINE
 ;
84 W !,"II-84  expr1 and expr2 are empty strings"
 S ^ABSN="20088",^ITEM="II-84  expr1 and expr2 are empty strings",^NEXT="85^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$L("",""),^VCORR="0" D ^VEXAMINE
 ;
85 W !,"II-85  expr1 is an empty string"
 S ^ABSN="20089",^ITEM="II-85  expr1 is an empty string",^NEXT="86^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$L("","A") S ^VCORR="1" D ^VEXAMINE
 ;
86 W !,"II-86  $L(expr1,expr2)=1"
 S ^ABSN="20090",^ITEM="II-86  $L(expr1,expr2)=1",^NEXT="87^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$L("ABC","D") S ^VCORR="1" D ^VEXAMINE
 ;
87 W !,"II-87  expr1 and expr2 are variables"
 S ^ABSN="20091",^ITEM="II-87  expr1 and expr2 are variables",^NEXT="88^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="",X="ABC",Y="EGF" S ^VCOMP=$l(X,Y),^VCORR=1 D ^VEXAMINE
 ;
88 W !,"II-88  $L(expr1,expr2)=256"
 S ^ABSN="20092",^ITEM="II-88  $L(expr1,expr2)=256",^NEXT="89^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="" S X="" F I=1:1:255 S X=X_"A"
 S ^VCOMP=$L($E(X,1,254),"A")_$L(X,"A") S ^VCORR="255256" D ^VEXAMINE
 ;
89 W !,"II-89  expr2 contains a control character"
 S ^ABSN="20093",^ITEM="II-89  expr2 contains a control character",^NEXT="90^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="" S A="" F I=1:1:99 S A=A_$C(9)
 S ^VCOMP=$L(A,$C(9)),^VCORR=100 D ^VEXAMINE
 ;
90 W !,"II-90  expr1 is a numeric literal"
 S ^ABSN="20094",^ITEM="II-90  expr1 is a numeric literal",^NEXT="95^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP=""
 S ^VCOMP=$L(001020304,0)_$L(13.5383,3)_$L(000.135383E2,3)_$L(-000.135373,3)
 S ^VCOMP=^VCOMP_$l(123456,123)_$l(123.456,3.4)_$l(1-0.0000001,10-1)_$l("000000",00000)
 S ^VCORR="44442287" D ^VEXAMINE
 ;
95 W !!,"$TEXT(+intexpr)  $TEXT(lineref)",!
 W !,"II-95  $TEXT"
 S ^ABSN="20095",^ITEM="II-95.1  intexpr=0",^NEXT="952^V2FN2,V2LHP1^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$t(+0)_"*"_$TEXT(+00.987)
 S ^VCORR="V2FN2*V2FN2" D ^VEXAMINE
 ;
952 S ^ABSN="20096",^ITEM="II-95.2  ls has multi spaces",^NEXT="V2LHP1^VV2" D ^V2PRESET
 ;(title corrected in V7.4;16/9/89)
 S ^VCOMP="" S ^VCOMP=$t(T95)_"*"_$TEXT(T95+1)
 S ^VCORR="T95 S A=1   ;$TEXT* S B=2   ;$TEXT+1"
 S ^VCORRN="T95       S A=1   ;$TEXT*                   S B=2   ;$TEXT+1" D EXAMINE2
 ;
T95       S A=1   ;$TEXT
                   S B=2   ;$TEXT+1
 ;
END W !!,"End of 9---V2FN2",!
 K  Q
 ;
EXAMINE2 I ^VCORR=^VCOMP D ^VEXAMINE Q
 I ^VCORRN=^VCOMP G FAIL90
 K ^VCORRN D ^VEXAMINE Q
FAIL90 ;
 S ^VREPORT="Part-84"
 K ^VREPORT(^VREPORT,^ABSN,"VCOMP"),^VREPORT(^VREPORT,^ABSN,"VCORR")
 W !,"** FAIL90  ",^ABSN," ",^ITEM S ^VREPORT(^VREPORT,^ABSN)="*FAIL90*" W:$Y>55 #
 S ^VREPORT(^VREPORT,^ABSN,"VCOMP")=^VCOMP
 S ^VREPORT(^VREPORT,^ABSN,"VCORR")=^VCORRN
 W !,"           COMPUTED =""",^VCOMP,"""" W:$Y>55 #
 W !,"           CORRECT  =""",^VCORR,"""" W:$Y>55 #
 K ^VCORRN
 H 1 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
