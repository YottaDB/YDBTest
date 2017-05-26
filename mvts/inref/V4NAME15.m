V4NAME15 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"36---V4NAME15:  $NAME function  -5-"
 ;
 W !!,"glvn=gvn"
 ;
1 S ^ABSN="40270",^ITEM="IV-270  unsubscripted"
 S ^NEXT="2^V4NAME15,V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$NA(^V)
 S ^VCORR="^V" D ^VEXAMINE
 ;
 W !,"1 subscript"
 ;
2 S ^ABSN="40271",^ITEM="IV-271  subscript is an integer number"
 S ^NEXT="3^V4NAME15,V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$name(^V(005423200))
 S ^VCORR="^V(5423200)" D ^VEXAMINE
 ;
3 S ^ABSN="40272",^ITEM="IV-272  subscript is a number"
 S ^NEXT="4^V4NAME15,V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$NA(^V(-0083484.4700E-2))
 S ^VCORR="^V(-834.8447)" D ^VEXAMINE
 ;
4 S ^ABSN="40273",^ITEM="IV-273  subscript is a string"
 S ^NEXT="5^V4NAME15,V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$na(^V("ZXCVBNM,./';][\=-`"))
 S ^VCORR="^V(""ZXCVBNM,./';][\=-`"")" D ^VEXAMINE
 ;
5 S ^ABSN="40274",^ITEM="IV-274  subscript contains a "" character"
 S ^NEXT="6^V4NAME15,V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$NA(^V("123""456"))
 S ^VCORR="^V(""123""""456"")" D ^VEXAMINE
 ;
6 S ^ABSN="40275",^ITEM="IV-275  subscript contains "" characters"
 S ^NEXT="V4NAME16^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$na(^V("0a""bc""""de""""""f"))
 S ^VCORR="^V(""0a""""bc""""""""de""""""""""""f"")" D ^VEXAMINE
 ;
END W !!,"End of 36 --- V4NAME15",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
