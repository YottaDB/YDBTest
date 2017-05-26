V3TR11 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"17---V3TR11: $TRANSLATE function -11-"
 ;
 W !!,"III-241  expr3 is a lvn",!
 ;
1 S ^ABSN="30241",^ITEM="III-241  expr3 is a lvn"
 S ^NEXT="2^V3TR11,V3TEXT^VV3" D ^V3PRESET
 s a("a","aa")="ef"
 S ^VCOMP=$TR("abcd","cd",a("a","aa"))
 S ^VCORR="abef" D ^VEXAMINE
 ;
 W !!,"III-242  expr3 is a gvn",!
 ;
2 S ^ABSN="30242",^ITEM="III-242  expr3 is a gvn"
 S ^NEXT="3^V3TR11,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","aa")="ef"
 S ^VCOMP=$TR("abcd","cd",^VV("a","aa"))
 S ^VCORR="abef" D ^VEXAMINE k ^VV
 ;
 W !!,"III-243  expr3 has unary operator",!
 ;
3 S ^ABSN="30243",^ITEM="III-243  expr3 has unary operator"
 S ^NEXT="4^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123","23",-+-+-''123)
 S ^VCORR="-01-1" D ^VEXAMINE
 ;
 W !!,"III-244  expr3 has binary operator",!
 ;
4 S ^ABSN="30244",^ITEM="III-244  expr3 has binary operator"
 S ^NEXT="5^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123","0123",123/10#10\1+1-1*1_121)
 S ^VCORR="-2121" D ^VEXAMINE
 ;
 W !!,"III-245  expr3 has function",!
 ;
5 S ^ABSN="30245",^ITEM="III-245  expr3 has function"
 S ^NEXT="6^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("abcdefgh","abcdef",$TR($TR($J(.23,6,3)," ",1),1))
 S ^VCORR="0.230gh" D ^VEXAMINE
 ;
 W !!,"III-246  expr3 has indirections",!
 ;
6 S ^ABSN="30246",^ITEM="III-246  expr3 has indirections"
 S ^NEXT="7^V3TR11,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c")="de",ab="^VV(""a"",""b"")",c1="c",c2="c1",d="@ab@(@c2)"
 S ^VCOMP=$TR("abc","ab",@d)
 S ^VCORR="dec" D ^VEXAMINE k ^VV
 ;
 W !!,"III-247  expr1 is an empty string",!
 ;
7 S ^ABSN="30247",^ITEM="III-247  expr1 is an empty string"
 S ^NEXT="8^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$translate("","ABCDEFGHIJ","abcdefghij")
 S ^VCORR="" D ^VEXAMINE
 ;
 W !!,"III-248  expr2 is an empty string",!
 ;
8 S ^ABSN="30248",^ITEM="III-248  expr2 is an empty string"
 S ^NEXT="9^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGHIJ","","abcd")
 S ^VCORR="ABCDEFGHIJ" D ^VEXAMINE
 ;
 W !!,"III-249  expr3 is an empty string",!
 ;
9 S ^ABSN="30249",^ITEM="III-249  expr3 is an empty string"
 S ^NEXT="10^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGHIJ","FGHIJ","")
 S ^VCORR="ABCDE" D ^VEXAMINE
 ;
 W !!,"III-250  Both expr2 and expr3 are empty strings",!
 ;
10 S ^ABSN="30250",^ITEM="III-250  Both expr2 and expr3 are empty strings"
 S ^NEXT="11^V3TR11,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","","")
 S ^VCORR="ABCDEFGH" D ^VEXAMINE
 ;
 W !!,"III-251  expr1, expr2, and expr3 are empty strings",!
 ;
11 S ^ABSN="30251",^ITEM="III-251  expr1, expr2, and expr3 are empty strings"
 S ^NEXT="V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("","","")
 S ^VCORR="" D ^VEXAMINE
 ;
END W !!,"End of 17 --- V3TR11",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
