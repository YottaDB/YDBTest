V3TR10 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"16---V3TR10: $TRANSLATE function -10-"
 ;
 W !!,"III-223  expr1 has function",!
 ;
1 S ^ABSN="30223",^ITEM="III-223  expr1 has function"
 S ^NEXT="2^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR($TR($J(.23,6,3)," ",1),1,"-")
 S ^VCORR="-0.230" D ^VEXAMINE
 ;
 W !!,"III-224  expr1 has indirection",!
 ;
2 S ^ABSN="30224",^ITEM="III-224  expr1 has indirections"
 S ^NEXT="3^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b")="ab",ab="^VV(""a"")",b1="b",b2="b1",c="@ab@(@b2)"
 S ^VCOMP=$TR(@c,"a","b")
 S ^VCORR="bb" D ^VEXAMINE k ^VV
 ;
 W !!,"III-225  expr2 is a strlit",!
 ;
3 S ^ABSN="30225",^ITEM="III-225  expr2 is a strlit"
 S ^NEXT="4^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("""123""","""""","ab")
 S ^VCORR="a123a" D ^VEXAMINE
 ;
 W !!,"expr2 is a numlit",!
 ;
4 S ^ABSN="30226",^ITEM="III-226  expr2 is 123456789012"
 S ^NEXT="5^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("012A345B",123456789012,"abcdef")
 S ^VCORR="abAcdeB" D ^VEXAMINE
 ;
5 S ^ABSN="30227",^ITEM="III-227  expr2 is -2.10"
 S ^NEXT="6^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-012",-2.10,"abcd")
 S ^VCORR="a0db" D ^VEXAMINE
 ;
6 S ^ABSN="30228",^ITEM="III-228  expr2 is 1.23E1"
 S ^NEXT="7^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123.456E789",1.23E1,"12.30")
 S ^VCORR="-0123.456E789" D ^VEXAMINE
 ;
7 S ^ABSN="30229",^ITEM="III-229  expr2 is ""1.23E1"""
 S ^NEXT="8^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123.456E789","1.23E1","12.3")
 S ^VCORR="-01.32456789" D ^VEXAMINE
 ;
 W !!,"III-230  expr2 is a lvn",!
 ;
8 S ^ABSN="30230",^ITEM="III-230  expr2 is a lvn"
 S ^NEXT="9^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a("a","aa")="cd"
 S ^VCOMP=$TR("abcd",a("a","aa"),"ab")
 S ^VCORR="abab" D ^VEXAMINE
 ;
 W !!,"III-231  expr2 is a gvn",!
 ;
9 S ^ABSN="30231",^ITEM="III-231  expr2 is a gvn"
 S ^NEXT="10^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","aa")="cd"
 S ^VCOMP=$TR("abcd",^VV("a","aa"),"ab")
 S ^VCORR="abab" D ^VEXAMINE k ^VV
 ;
 W !!,"III-232  expr2 has unary operator",!
 ;
10 S ^ABSN="30232",^ITEM="III-232  expr2 has unary operator"
 S ^NEXT="11^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123",-+-+-''123,"+4")
 S ^VCORR="+0423" D ^VEXAMINE
 ;
 W !!,"III-233  expr2 has binary operator",!
 ;
11 S ^ABSN="30233",^ITEM="III-233  expr2 has binary operator"
 S ^NEXT="12^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123",123/10#10\1+1-1*1_121,"3456")
 S ^VCORR="-0433" D ^VEXAMINE
 ;
 W !!,"III-234  expr2 has function",!
 ;
12 S ^ABSN="30234",^ITEM="III-234  expr2 has function"
 S ^NEXT="13^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("012.34",$TR($J(.23,6,3)," ",1),"00000a")
 S ^VCORR="000004" D ^VEXAMINE
 ;
 W !!,"III-235  expr2 has indirections",!
 ;
13 S ^ABSN="30235",^ITEM="III-235  expr2 has indirections"
 S ^NEXT="14^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b")="ab",ab="^VV(""a"")",b1="b",b2="b1",c="@ab@(@b2)"
 S ^VCOMP=$TR("abc",@c,"de")
 S ^VCORR="dec" D ^VEXAMINE k ^VV
 ;
 W !!,"III-236  expr3 is a strlit",!
 ;
14 S ^ABSN="30236",^ITEM="III-236  expr3 is a strlit"
 S ^NEXT="15^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("""abc""","abc","""""""")
 S ^VCORR="""""""""""" D ^VEXAMINE
 ;
 W !!,"expr3 is a numlit",!
 ;
15 S ^ABSN="30237",^ITEM="III-237  expr3 is 123456789012"
 S ^NEXT="16^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("abcdefghijkl","abcdefghijkl",123456789012)
 S ^VCORR="123456789012" D ^VEXAMINE
 ;
16 S ^ABSN="30238",^ITEM="III-238  expr3 is -2.10"
 S ^NEXT="17^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("+012","+2.10",-2.10)
 S ^VCORR="-12" D ^VEXAMINE
 ;
17 S ^ABSN="30239",^ITEM="III-239  expr3 is 1.23E1"
 S ^NEXT="18^V3TR10,V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123.456E789","12.30",1.23E1)
 S ^VCORR="-123.456E789" D ^VEXAMINE
 ;
18 S ^ABSN="30240",^ITEM="III-240  expr3 is ""1.23E1"""
 S ^NEXT="V3TR11^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123.456E789","-12.3","1.23E1")
 S ^VCORR="10.2E3456E789" D ^VEXAMINE
 ;
END W !!,"End of 16 --- V3TR10",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
