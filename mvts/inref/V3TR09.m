V3TR09 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"15---V3TR09: $TRANSLATE function -9-"
 ;
 W !!,"Both expr1 and expr2 have control chars",!
 ;
1 S ^ABSN="30209",^ITEM="III-209  Both expr1 and expr2 have control chars"
 S ^NEXT="2^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a="" f i=0:1:127 s a=a_$c(i)
 s b="" f i=0:1:63  s b=b_$c(i)
 S ^VCOMP=$TR(a,b,"abc")
 s c="abc" f i=64:1:127 s c=c_$c(i)
 S ^VCORR=c D ^VEXAMINE
 ;
 W !!,"III-210  Both expr1 and expr3 have control chars",!
 ;
2 S ^ABSN="30210",^ITEM="III-210  Both expr1 and expr3 have control chars"
 S ^NEXT="3^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR($C(0,13,12,13)_"a","a",$C(10))
 S ^VCORR=$C(0,13,12,13,10) D ^VEXAMINE
 ;
 W !!,"III-211  Both expr2 and expr3 have control chars",!
 ;
3 S ^ABSN="30211",^ITEM="III-211  Both expr2 and expr3 have control chars"
 S ^NEXT="4^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a="" f i=0:1:15 s a=a_$c(i)
 s b="" f i=16:1:31  s b=b_$c(i)
 S ^VCOMP=$TR("""!@",a,b)
 S ^VCORR="""!@" D ^VEXAMINE
 ;
 W !!,"III-212  expr1, expr2, and expr3 have control chars",!
 ;
4 S ^ABSN="30212",^ITEM="III-212  expr1, expr2, and expr3 have control chars"
 S ^NEXT="5^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a="" f i=0:1:14 s a=a_$c(i)
 s b="" f i=0:1:9 s b=b_$c(i)
 s c="" f i=16:1:31  s c=c_$c(i)
 S ^VCOMP=$TR(a,b,c)
 s d="" f i=16:1:25 s d=d_$c(i)
 f i=10:1:14 s d=d_$c(i)
 S ^VCORR=d D ^VEXAMINE
 ;
 W !!,"III-213  expr1 is a strlit",!
 ;
5 S ^ABSN="30213",^ITEM="III-213  expr1 is a strlit"
 S ^NEXT="6^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("1E1""""","E"""," a")
 S ^VCORR="1 1aa" D ^VEXAMINE
 ;
 W !!,"expr1 is a numlit",!
 ;
6 S ^ABSN="30214",^ITEM="III-214  expr1 is 123456789012"
 S ^NEXT="7^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(123456789012,"12","01")
 S ^VCORR="013456789001" D ^VEXAMINE
 ;
7 S ^ABSN="30215",^ITEM="III-215  expr1 is -1.1, expr2 is a period"
 S ^NEXT="8^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(-1.1,".","2")
 S ^VCORR="-121" D ^VEXAMINE
 ;
8 S ^ABSN="30216",^ITEM="III-216  expr1 is -1.1, expr2 is a minus"
 S ^NEXT="9^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$tr(-1.1,"-","+")
 S ^VCORR="+1.1" D ^VEXAMINE
 ;
9 S ^ABSN="30217",^ITEM="III-217  expr1 is 1.23E1"
 S ^NEXT="10^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(1.23E1,"1","E")
 S ^VCORR="E2.3" D ^VEXAMINE
 ;
10 S ^ABSN="30218",^ITEM="III-218  expr1 is ""1.23E1"""
 S ^NEXT="11^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("1.23E1","E","+")
 S ^VCORR="1.23+1" D ^VEXAMINE
 ;
 W !!,"III-219  expr1 is a lvn",!
 ;
11 S ^ABSN="30219",^ITEM="III-219  expr1 is a lvn"
 S ^NEXT="12^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a("a","aa")="abcdefghij"
 S ^VCOMP=$TR(a("a","aa"),"a","b")
 S ^VCORR="bbcdefghij" D ^VEXAMINE
 ;
 W !!,"III-220  expr1 is a gvn",!
 ;
12 S ^ABSN="30220",^ITEM="III-220  expr1 is a gvn"
 S ^NEXT="13^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","aa")="abcdefghij"
 S ^VCOMP=$TR(^VV("a","aa"),"a","b")
 S ^VCORR="bbcdefghij" D ^VEXAMINE K ^VV
 ;
 W !!,"III-221  expr1 has unary operator",!
 ;
13 S ^ABSN="30221",^ITEM="III-221  expr1 has unary operator"
 S ^NEXT="14^V3TR09,V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(-+-+-''123,"-","'")
 S ^VCORR="'1" D ^VEXAMINE
 ;
 W !!,"III-222  expr1 has binary operator",!
 ;
14 S ^ABSN="30222",^ITEM="III-222  expr1 has binary operator"
 S ^NEXT="V3TR10^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(123/10#10\1+1-1*1_121,"1",".")
 S ^VCORR="2.2." D ^VEXAMINE
 ;
END W !!,"End of 15 --- V3TR09",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
