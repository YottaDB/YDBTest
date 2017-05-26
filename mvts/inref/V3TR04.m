V3TR04 ;IW-KO-YS-TS,V3TR,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"10---V3TR04: $TRANSLATE function -4-"
 W !!,"III-134  expr2 is a lvn",!
 ;
1 S ^ABSN="30134",^ITEM="III-134  expr2 is a lvn"
 S ^NEXT="2^V3TR04,V3TR05^V3TR,V3TEXT^VV3" D ^V3PRESET
 s a("a","aa")="cd"
 S ^VCOMP=$TR("abcd",a("a","aa"))
 S ^VCORR="ab" D ^VEXAMINE
 ;
 W !!,"III-135  expr2 is a gvn",!
 ;
2 S ^ABSN="30135",^ITEM="III-135  expr2 is a gvn"
 S ^NEXT="3^V3TR04,V3TR05^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","aa")="cd"
 S ^VCOMP=$TR("abcd",^VV("a","aa"))
 S ^VCORR="ab" D ^VEXAMINE k ^VV
 ;
 W !!,"III-136  expr2 has unary operator",!
 ;
3 S ^ABSN="30136",^ITEM="III-136  expr2 has unary operator"
 S ^NEXT="4^V3TR04,V3TR05^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR(-+-+-''123,"-")
 S ^VCOMP=$TR("-0123",-+-+-''123)
 S ^VCORR="023" D ^VEXAMINE
 ;
 W !!,"III-137  expr2 has binary operator",!
 ;
4 S ^ABSN="30137",^ITEM="III-137  expr2 has binary operator"
 S ^NEXT="5^V3TR04,V3TR05^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR("-0123",123/10#10\1+1-1*1_121)
 S ^VCORR="-03" D ^VEXAMINE
 ;
 W !!,"III-138  expr2 has function",!
 ;
5 S ^ABSN="30138",^ITEM="III-138  expr2 has function"
 S ^NEXT="6^V3TR04,V3TR05^V3TR,V3TEXT^VV3" D ^V3PRESET
 S ^VCOMP=$TR($TR("ABCDABCD","CD"),$TR($E($P("ABCDE,BCDEF,CDEFG",","),1,3),"BC"))
 S ^VCORR="BB" D ^VEXAMINE
 ;
 W !!,"III-139  expr2 has indirection",!
 ;
6 S ^ABSN="30139",^ITEM="III-139  expr2 has indirection"
 S ^NEXT="V3TR04^V3TR,V3TEXT^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b")="ab",ab="^VV(""a"")",b1="b",b2="b1"
 S ^VCOMP=$TR("abc",@ab@(@b2))
 S ^VCORR="c" D ^VEXAMINE k ^VV
 ;
END W !!,"End of 10 --- V3TR04",!
 K  k ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
