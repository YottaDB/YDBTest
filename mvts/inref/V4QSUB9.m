V4QSUB9 ;IW-KO-YS-TS,V4QSUB,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"62---V4QSUB9:  $QSUBSCRIPT function  -9-"
 ;
 W !!,"gvn"
 W !!,"intexpr=0"
 ;
1 S ^ABSN="40457",^ITEM="IV-457  unsubscripted"
 S ^NEXT="2^V4QSUB9,V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$QSUBSCRIPT("^V",0)
 S ^VCORR="^V" D ^VEXAMINE
 ;
 W !!,"1 subscript"
 ;
2 S ^ABSN="40458",^ITEM="IV-458  subscript is an integer number"
 S ^NEXT="3^V4QSUB9,V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qsubscript("^V(0)",0)
 S ^VCORR="^V" D ^VEXAMINE
 ;
3 S ^ABSN="40459",^ITEM="IV-459  subscript is a number"
 S ^NEXT="4^V4QSUB9,V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qsubscript("^VAAAAAAA(-27364.363)",0)
 S ^VCORR="^VAAAAAAA" D ^VEXAMINE
 ;
4 S ^ABSN="40460",^ITEM="IV-460  subscript is a string"
 S ^NEXT="5^V4QSUB9,V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$QS("^VABCD(""abcd"")",0)
 S ^VCORR="^VABCD" D ^VEXAMINE
 ;
5 S ^ABSN="40461",^ITEM="IV-461  subscript contains a "" character"
 S ^NEXT="6^V4QSUB9,V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S ^VCOMP=$qs("^V(""a""""b"")",0)
 S ^VCORR="^V" D ^VEXAMINE
 ;
6 S ^ABSN="40462",^ITEM="IV-462  subscript contains "" characters"
 S ^NEXT="V4QSUB10^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qs("^V(""a""""b"")",0)
 S ^VCORR="^V" D ^VEXAMINE
 ;
END W !!,"End of 62 --- V4QSUB9",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
