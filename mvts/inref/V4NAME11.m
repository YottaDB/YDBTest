V4NAME11 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"32---V4NAME11:  $NAME function  -1-"
 ;
 W !!,"$NAME(glvn)"
 W !,"glvn=lvn"
 ;
1 S ^ABSN="40243",^ITEM="IV-243  unsubscripted"
 S ^NEXT="2^V4NAME11,V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET
 S ^VCOMP=$NAME(VV)
 S ^VCORR="VV" D ^VEXAMINE
 ;
 W !,"1 subscript"
 ;
2 S ^ABSN="40244",^ITEM="IV-244  subscript is an integer number"
 S ^NEXT="3^V4NAME11,V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$name(ABCDEFGH(000456))
 S ^VCORR="ABCDEFGH(456)" D ^VEXAMINE
 ;
3 S ^ABSN="40245",^ITEM="IV-245  subscript is a number"
 S ^NEXT="4^V4NAME11,V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$NA(VV001(-4596E-5))
 S ^VCORR="VV001(-.04596)" D ^VEXAMINE
 ;
4 S ^ABSN="40246",^ITEM="IV-246  subscript is a string"
 S ^NEXT="5^V4NAME11,V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$na(VV001("abcdef"))
 S ^VCORR="VV001(""abcdef"")" D ^VEXAMINE
 ;
5 S ^ABSN="40247",^ITEM="IV-247  subscript contains a "" character"
 S ^NEXT="6^V4NAME11,V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$na(VV001("abc""def"))
 S ^VCORR="VV001(""abc""""def"")" D ^VEXAMINE
 ;
6 S ^ABSN="40248",^ITEM="IV-248  subscript contains "" characters"
 S ^NEXT="V4NAME12^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$na(VV001("a""bc""""de""""""f"))
 S ^VCORR="VV001(""a""""bc""""""""de""""""""""""f"")" D ^VEXAMINE
 ;
END W !!,"End of 32 --- V4NAME11",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
