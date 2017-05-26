V4GET23 ;IW-KO-YS-TS,V4GET2,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"25---V4GET23:  $GET function  -3-"
 ;
1 S ^ABSN="40191",^ITEM="IV-191  expr is an empty string"
 S ^NEXT="2^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 s AAAA="A(""ABC"")"
 S ^VCOMP=$get(@AAAA,"")
 S ^VCORR="" D ^VEXAMINE
 ;
2 S ^ABSN="40192",^ITEM="IV-192  expr is an integer number"
 S ^NEXT="3^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 S ^VCOMP=$g(C(1,2,3,4,5,6,7,8,9,10),1E25)
 S ^VCORR="10000000000000000000000000" D ^VEXAMINE
 ;
3 S ^ABSN="40193",^ITEM="IV-193  expr is a number"
 S ^NEXT="4^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 S ^VCOMP=$g(@"AA",-1E-25)
 S ^VCORR="-.0000000000000000000000001" D ^VEXAMINE
 ;
4 S ^ABSN="40194",^ITEM="IV-194  expr is a string"
 S ^NEXT="5^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 S ^VCOMP=$g(AA(1),"1.0")
 S ^VCORR="1.0" D ^VEXAMINE
 ;
5 S ^ABSN="40195",^ITEM="IV-195  expr is a string with maximum length"
 S ^NEXT="6^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 s MAX=$j("",255),X=""
 s X=X_"                                                                 "
 s X=X_"                                                                 "
 s X=X_"                                                                 "
 s X=X_"                                                            "
 S ^VCOMP=$g(AA,MAX)
 S ^VCORR=X D ^VEXAMINE
 ;
6 S ^ABSN="40196",^ITEM="IV-196  expr is a naked reference"
 S ^NEXT="7^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 s ^VV("A",1,2,3)="A123"
 s ^VV("A",1,2,4)="A124"
 s ^VV("A",4)="A4"
 s ^VV("B",1,2,3)="B123"
 s ^VV("B",1,2,4)="B124"
 s ^VV("B",1)="B1"
 S A(1)=1
 S ^VCOMP=$g(A($d(^VV("A",1))),^(1,2,3))_" "_^(4)
 S ^VCORR="A123 A124" D ^VEXAMINE K ^VV
 ;
7 S ^ABSN="40197",^ITEM="IV-197  expr is a lvn"
 S ^NEXT="8^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 S A="A",A(3)=3,A(2,3)=23,A(2.1)=2.1
 S ^VCOMP=$GET(A(6/3),A(2,3))
 S ^VCORR="23" D ^VEXAMINE
 ;
8 S ^ABSN="40198",^ITEM="IV-198  expr is a gvn"
 S ^NEXT="9^V4GET23,V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S A="B",B="C",C="D",VV("D")="DD"
 S ^VV("A")="A",^VV(1,"A")=21
 S ^VV("B")="B",^VV(1,"B")=22
 S ^VCOMP=$G(VV(@@A),^VV(1,"A"))_" "_^("B")
 S ^VCORR="DD 22" D ^VEXAMINE K ^VV
 ;
9 S ^ABSN="40199",^ITEM="IV-199  expr is a svn"
 S ^NEXT="V4GET24^V4GET2,V4NAME^VV4" D ^V4PRESET K
 I 1 S A=12
 S:A=13 H(1)=123
 S ^VCOMP=$G(H(1),$TEST)
 S ^VCORR="1" D ^VEXAMINE
 ;
END W !!,"End of 25 --- V4GET23",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
