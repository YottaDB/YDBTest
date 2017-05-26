V3TR08 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"14---V3TR08: $TRANSLATE function -8-"
 ;
1 S ^ABSN="30196",^ITEM="III-196  3 middle chars and tailing 3 chars are changed"
 S ^NEXT="2^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEABCDE","CDE","cde")
 S ^VCORR="ABcdeABcde" D ^VEXAMINE
 ;
2 S ^ABSN="30197",^ITEM="III-197  A middle and tailing substrings are changed"
 S ^NEXT="3^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCCBADEFFEDABCCBAFEDDD","DEF","def")
 S ^VCORR="ABCCBAdeffedABCCBAfeddd" D ^VEXAMINE
 ;
3 S ^ABSN="30198",^ITEM="III-198  All chars are changed"
 S ^NEXT="4^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCBAABCBA","ABC","abc")
 S ^VCORR="abcbaabcba" D ^VEXAMINE
 ;
 W !!,"III-199  expr1 has 255 chars",!
 ;
4 S ^ABSN="30199",^ITEM="III-199  expr1 has 255 chars"
 S ^NEXT="5^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S a="" f i=1:1:51 s a=a_"ABCDE"
 S ^VCOMP=$TR(a,"AB","ab")
 s b="" f i=1:1:51 s b=b_"abCDE"
 S ^VCORR=b D ^VEXAMINE
 ;
 W !!,"III-200  expr2 has 255 chars",!
 ;
5 S ^ABSN="30200",^ITEM="III-200  expr2 has 255 chars"
 S ^NEXT="6^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a="" f i=1:1:51 s a=a_"ABCDE"
 S ^VCOMP=$TR("ABCDEFGHIJ",a,"abc")
 S ^VCORR="abcFGHIJ" D ^VEXAMINE
 ;
 W !!,"III-201  expr3 has 255 chars",!
 ;
6 S ^ABSN="30201",^ITEM="III-201  expr3 has 255 chars"
 S ^NEXT="7^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a="" f i=1:1:51 s a=a_"abcde"
 S ^VCOMP=$TR("ABCDEFGHIJ","ABC",a)
 S ^VCORR="abcDEFGHIJ" D ^VEXAMINE
 ;
 W !!,"III-202  expr1, expr3, and expr3 have 255 chars",!
 ;
7 S ^ABSN="30202",^ITEM="III-202  expr1, expr2, and expr3 have 255 chars"
 S ^NEXT="8^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S a="" f i=1:1:51 s a=a_"ABCDE"
 s b="" f i=1:1:85 s b=b_"ABC"
 s c="" f i=1:1:51 s c=c_"abcde"
 S ^VCOMP=$TR(a,b,c)
 s d="" f i=1:1:51 s d=d_"abcDE"
 S ^VCORR=d D ^VEXAMINE
 ;
 W !!,"III-203  $L(expr2)<$L(expr3)",!
 ;
8 S ^ABSN="30203",^ITEM="III-203  $L(expr2)<$L(expr3)"
 S ^NEXT="9^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGHIJ","ABC","abcdef")
 S ^VCORR="abcDEFGHIJ" D ^VEXAMINE
 ;
 W !!,"III-204  $L(expr2)=$L(expr3)",!
 ;
9 S ^ABSN="30204",^ITEM="III-204  $L(expr2)=$L(expr3)"
 S ^NEXT="10^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGHIJ","ABCDEKLMNO","abcdeklmno")
 S ^VCORR="abcdeFGHIJ" D ^VEXAMINE
 ;
 W !!,"III-205  $L(expr2)>$L(expr3)",!
 ;
10 S ^ABSN="30205",^ITEM="III-205  $L(expr2)>$L(expr3)"
 S ^NEXT="11^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGHIJ","ACEGI","ace")
 S ^VCORR="aBcDeFHJ" D ^VEXAMINE
 ;
 W !!,"III-206  expr1 has control chars",!
 ;
11 S ^ABSN="30206",^ITEM="III-206  expr1 has control chars"
 S ^NEXT="12^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABC"_$C(13,12,0)_"DEF","DEF","def")
 S ^VCORR="ABC"_$C(13,12,0)_"def" D ^VEXAMINE
 ;
 W !!,"expr2 has control chars",!
 ;
12 S ^ABSN="30207",^ITEM="III-207  expr2 has control chars"
 S ^NEXT="13^V3TR08,V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH",$C(13,10),"ab")
 S ^VCORR="ABCDEFGH" D ^VEXAMINE
 ;
13 S ^ABSN="30208",^ITEM="III-208  expr3 has control chars"
 S ^NEXT="V3TR09^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("ABCDEFGH","ABCD",$C(13,10,13,12))
 S ^VCORR=$C(13,10,13,12)_"EFGH" D ^VEXAMINE
 ;
END W !!,"End of 14 --- V3TR08",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
