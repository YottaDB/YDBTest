V4GET26 ;IW-KO-YS-TS,V4GET2,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"28---V4GET26:  $GET function  -6-"
 ;
 W !,"gvn has indirections"
 ;
1 S ^ABSN="40215",^ITEM="IV-215  ^VV(@A)"
 S ^NEXT="2^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S A="@^VV($E(""ABCDE"",2,3))",^VV("BC")="^VV(0)",^VV(0)="ZZZ"
 S ^VV("ZZZ")="zzz"
 S ^VCOMP=$g(^VV(@A),123)
 S ^VCORR="zzz" D ^VEXAMINE K ^VV
 ;
2 S ^ABSN="40216",^ITEM="IV-216  @^VV"
 S ^NEXT="3^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S B="B"
 S ^VV="@VV@(B,""C"")",VV="@^VV(""A"")",^VV("A")="^VV(""a"")"
 S ^VV("a",B,"C")="aBC"
 S ^VCOMP=$G(@^VV,2)
 S ^VCORR="aBC" D ^VEXAMINE K ^VV
 ;
3 S ^ABSN="40217",^ITEM="IV-217  @^VV@(12,456)"
 S ^NEXT="4^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S Y="y",X="X(1)",X1="X(1)",X(1)=3
 S ^VV="@^VV(""X"",@X1)@(@X)",^VV(1)="^VV(""X"")",^VV("X",3)="^VV(Y,Y)"
 S ^VV("y","y",3,12,456)="QQQ"
 S ^VCOMP=$G(@^VV@(12,456),1)
 S ^VCORR="QQQ" D ^VEXAMINE K ^VV
 ;
; **MVTS LOCAL CHANGE**
; The below test was disabled 10/2001 by SE and reenabled 11/2012. BC
;
4 S ^ABSN="40218",^ITEM="IV-218  @@^VV(0)@(12,456)"
 S ^NEXT="5^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S X="X"
 S ^VV("GGG","X")="gggX"
 S ^VV(0)="@@@^VV(1)",^VV(1)="^VV(2)",^VV(2)="@^VV(1+2)@(8/2)"
 S ^VV(3)="^VV(X)",^VV("X",4)="^VV(""A"",""B"")"
 S ^VV("A","B",12,456)="^VV(""GGG"",@@@@@@@@X)"
 S ^VCOMP=$G(@@^VV(0)@(12,456),5)
 S ^VCORR="gggX" D ^VEXAMINE K ^VV
 ;
5 S ^ABSN="40219",^ITEM="IV-219  nesting"
 S ^NEXT="6^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S A="^VV(A)",^VV("^VV(A)")="@($E(""ABCDEFGHI"",2,3)_""(3)"")@(5,6)"
 S BC(3)="^VV(123)"
 S ^VCOMP=$G(@@A,A)
 S ^VCORR="^VV(A)" D ^VEXAMINE
 ;
6 S ^ABSN="40220",^ITEM="IV-220  gvn contains extrinsic special variable"
 S ^NEXT="7^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S ^VV("ABC")="abc"
 S ^VCOMP=$g(@$$GVN^V4GETE,$$GVN^V4GETE)
 S ^VCORR="abc" D ^VEXAMINE K ^VV
 ;
7 S ^ABSN="40221",^ITEM="IV-221  gvn contains extrinsic function"
 S ^NEXT="8^V4GET26,V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S A="A",B="B",C="^VV"
 S ^VCOMP=$g(@($$ABC^V4GETE(A,.B,.C)_"(1)"),B)
 S ^VCORR="A/B/" D ^VEXAMINE K ^VV
 ;
8 S ^ABSN="40222",^ITEM="IV-222  gvn contains nesting functions"
 S ^NEXT="V4GET27^V4GET2,V4NAME^VV4" D ^V4PRESET K
 S A="AWWY",B="B",C="C",N=12345678,AXBXC=9
 S ^VV(9)="TR"
 S ^VCOMP=$g(@$TR($$^V4GETE(A,.B,.C)," WYabcAB","XV(AB)^"),$FN(N,","))
 S ^VCORR="TR" D ^VEXAMINE
 ;
END W !!,"End of 28 --- V4GET26",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
