V4NAME25 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"44---V4NAME25:  $NAME function  -13-"
 ;
1 S ^ABSN="40324",^ITEM="IV-324  glvn contains operators"
 S ^NEXT="2^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A=4.02
 S ^VCOMP=$NA(^V(-($j(1234.5678E-4,0,2)),--A,-+A),--10)
 S ^VCORR="^V(-.12,4.02,-4.02)" D ^VEXAMINE
 ;
2 S ^ABSN="40325",^ITEM="IV-325  glvn contains naked refernce"
 S ^NEXT="3^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V("A",1,1)="A11",^V("B",1,1)="B11"
 S ^V("A",1)="A1",^V("B",1)="B1"
 S ^VCOMP=$na(^V(^(1),^(1,1),^V("A",1),^(1),^(1,1)),3)
 S ^VCORR="^V(""B1"",""B11"",""A1"")" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40326",^ITEM="IV-326  glvn has indirections"
 S ^NEXT="4^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V("C",4,5,3)="",^V("A")=2
 S ^V="^V(""A"")",^V("A",1,2)="^V(""C"",4)"
 S ^VCOMP=$na(@@^V@(1,@^V)@(5,2),$O(@@^V@(1,2)@(5,@^V)))
 S ^VCORR="^V(""C"",4,5)" D ^VEXAMINE
 ;
 W !,"glvn contains functions"
 ;
4 S ^ABSN="40327",^ITEM="IV-327  glvn contains $GET function"
 S ^NEXT="5^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V="^VV"
 S ^VCOMP=$na(@$Get(^V($G(A,"A"),"B"),$GET(A,^V)),4)
 S ^VCORR="^VV" D ^VEXAMINE
 ;
5 S ^ABSN="40328",^ITEM="IV-328  glvn contains $ORDER function"
 S ^NEXT="6^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V("A","B")="AB",A="A",^V("C",2)="#"
 S ^VCOMP=$NAME(^V($O(^V(A)),$O(^(2))),$o(^("C","")))_" "_^(2)
 S ^VCORR="^V(""C"",""A"") #" D ^VEXAMINE
 ;
6 S ^ABSN="40329",^ITEM="IV-329  glvn contains $QUERY function"
 S ^NEXT="7^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 s ^V("a","a")="",^V("a","b","a")="a",^V("a","b","c")=""
 S ^VCOMP=$Na(@$Q(^(^("a"))),2)
 S ^VCORR="^V(""a"",""b"")" D ^VEXAMINE K ^V
 ;
7 S ^ABSN="40330",^ITEM="IV-330  glvn contains $SELECT function"
 S ^NEXT="8^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V="B"
 S ^VCOMP=$NA(@$S(^V="A":"^V(1)",^V="B":"^V(1,2,3)",1:"A"),2)
 S ^VCORR="^V(1,2)" D ^VEXAMINE
 ;
8 S ^ABSN="40331",^ITEM="IV-331  glvn contains $NAME function"
 S ^NEXT="9^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$NA(@$NA(^V(1,2,3,4,5),0),5)
 S ^VCORR="^V" D ^VEXAMINE
 ;
9 S ^ABSN="40332",^ITEM="IV-332  glvn contains extrinsic special variable"
 S ^NEXT="10^V4NAME25,V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A=5
 S ^VCOMP=$NA(^V($$SUB,$$SUB,$$SUB),$$SUB)
 S ^VCORR="^V(4)" D ^VEXAMINE
 ;
10 S ^ABSN="40333",^ITEM="IV-333  glvn contains extrinsic function"
 S ^NEXT="V4NAME26^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S AA="aa",^V(1)=1,^V("A")="^V(""a"")"
 S ^VCOMP=$NA(@$$NAM@(@$$NAM(1),@$$NAM(2)),$$NAM(3))
 S ^VCORR="^V(""A"",""aa"")" D ^VEXAMINE
 ;
END W !!,"End of 44 --- V4NAME25",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
SUB() S A=A-1 Q A
NAM(X,Y) ;
 I $D(X)=0 Q "^V(""A"")"
 I X=1 Q "AA"
 I X=2 Q "^V(1)"
 I X=3 Q 2
