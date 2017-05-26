V4QLEN2 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"47---V4QLEN2:  $QLENGTH function  -2-"
 ;
 W !!,"2 subscripts"
 ;
1 S ^ABSN="40348",^ITEM="IV-348  subscript is an integer number"
 S ^NEXT="2^V4QLEN2,V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 K VV S VV(123,999)="2"
 S ^VCOMP=$QL("VV(123,999)")
 S ^VCORR="2" D ^VEXAMINE
;**MVTS LOCAL CHANGE**
;Current requirement is for canonic input 10/2001 SE
 ;
2 ;S ^ABSN="40349",^ITEM="IV-349  subscript is a number"
 ;S ^NEXT="3^V4QLEN2,V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 ;K VV S VV(-.00024,45)="A"
 ;S ^VCOMP=$ql("VV(-24E-5,45)")
 ;S ^VCORR="2" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
;Current requirement is for canonic input 10/2001 SE
3 ;S ^ABSN="40350",^ITEM="IV-350  subscript are numbers"
 ;S ^NEXT="4^V4QLEN2,V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 ;K VV S VV(-.00024,45000)="A"
 ;S ^VCOMP=$QL("VV(-24E-5,45E+3)")
 ;S ^VCORR="2" D ^VEXAMINE
 ;
4 S ^ABSN="40351",^ITEM="IV-351  subscript is a string"
 S ^NEXT="5^V4QLEN2,V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 K VV S VV("-A","123")="ABC"
 S ^VCOMP=$ql("VV(""-A"",""123"")")
 S ^VCORR="2" D ^VEXAMINE
 ;
5 S ^ABSN="40352",^ITEM="IV-352  subscript are strings"
 S ^NEXT="6^V4QLEN2,V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 K VV S VV("-A","123.")="ABC"
 S ^VCOMP=$ql("VV(""-A"",""123."")")
 S ^VCORR="2" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
;Current requirement is for canonic input 10/2001 SE
6 ;S ^ABSN="40353",^ITEM="IV-353  5 subscripts"
 ;S ^NEXT="V4QLEN3^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 ;K A S A(123,"ABC","0",0.003,"X4")="AA"
 ;S ^VCOMP=$QL("A(123,""ABC"",""0"",0.003,""X4"")")
 ;S ^VCORR="5" D ^VEXAMINE
 ;
END W !!,"End of 47 --- V4QLEN2",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
