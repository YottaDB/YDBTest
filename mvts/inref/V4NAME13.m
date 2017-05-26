V4NAME13 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"34---V4NAME13:  $NAME function  -3-"
 ;
1 S ^ABSN="40257",^ITEM="IV-257  lvn contains operators"
 S ^NEXT="2^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$na(V(1+1,'0,--2,"ABC"_"DEF","ABC"["D"))
 S ^VCORR="V(2,1,2,""ABCDEF"",0)" D ^VEXAMINE
 ;
2 S ^ABSN="40258",^ITEM="IV-258  lvn contains naked refernce"
 S ^NEXT="3^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^VV
 S ^VV("A",1,1)="A11",^VV("B",1,1)="B11"
 S ^VV("A",1)="A1",^VV("B",1)="B1"
 S ^VCOMP=$na(ABC(^(1),^(1,1),^VV("A",1),^(1),^(1,1)))
 S ^VCORR="ABC(""B1"",""B11"",""A1"",""A1"",""A11"")" D ^VEXAMINE K ^VV
 ;
3 S ^ABSN="40259",^ITEM="IV-259  lvn has indirections"
 S ^NEXT="4^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S VV(0)="V(""A"",34.4E-1)",V("A",3.44)="V(003.44,5.6)"
 S V(003.44000,0005.600)="VV(""A"",3.44)"
 S V("A",3.44,12,456)="@V(003.44,5.6)"
 S V(03.44,5.6)="V(-456,67)",V(-456,67)="NEST"
 S ^VCOMP=$NA(@@@VV(0)@(12,456))
 S ^VCORR="NEST" D ^VEXAMINE
 ;
 W !,"lvn contains functions"
 ;
4 S ^ABSN="40260",^ITEM="IV-260  lvn contains $GET function"
 S ^NEXT="5^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 s NAM("A","B")="VV(""A"")",VV("A")="A"
 S BB="B(1)",CC="C1"
 S ^VCOMP=$na(@NAM($g(VV("A"),"A"),$g(AA(1),"B")))
 S ^VCORR="VV(""A"")" D ^VEXAMINE
 ;
5 S ^ABSN="40261",^ITEM="IV-261  lvn contains $ORDER function"
 S ^NEXT="6^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^VV
 S ^VV("abc")="",^VV("x")=""
 S ^VCOMP=$na(V($O(^VV(""))))
 S ^VCORR="V(""abc"")" D ^VEXAMINE K ^VV
 ;
6 S ^ABSN="40262",^ITEM="IV-262  lvn contains $QUERY function"
 S ^NEXT="7^V4NAME13,V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 s A("a","b","c","d","e","f","g","h")=""
 s A("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t")=""
 S ^VCOMP=$NA(@$Q(A("a","b","c","d","e","f","g","h","i")))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"",""l"",""m"",""n"",""o"",""p"",""q"",""r"",""s"",""t"")" D ^VEXAMINE
 ;
7 S ^ABSN="40263",^ITEM="IV-263  lvn contains $SELECT function"
 S ^NEXT="V4NAME14^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 I 1
 S ^VCOMP=$name(AA($S(0:"A",$T:"B",1:"C")))
 S ^VCORR="AA(""B"")" D ^VEXAMINE
 ;
END W !!,"End of 34 --- V4NAME13",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
