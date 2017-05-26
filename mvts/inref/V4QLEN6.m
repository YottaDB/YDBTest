V4QLEN6 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"51---V4QLEN6:  $QLENGTH function  -6-"
 ;
 W !!,"2 subscripts"
 ;
1 S ^ABSN="40378",^ITEM="IV-378  subscript is an integer number"
 S ^NEXT="2^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$ql("^V(94378438,""A"")")
 S ^VCORR="2" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
;Current requirement is for canonic input 04/2010 SE
2 ;S ^ABSN="40379",^ITEM="IV-379  subscript is a number"
 ;S ^NEXT="3^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 ;S ^V(-0000.00003)="A"
 ;S ^VCOMP=$ql("^V(-0000.00003,""ZZZZZZ"")")
 ;S ^VCORR="2" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
;Current requirement is for canonic input 10/2001 SE
3 ;S ^ABSN="40380",^ITEM="IV-380  subscript are numbers"
 ;S ^NEXT="4^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 ;S ^VCOMP=$QL("^V(3787.4300000,-00093.9999999900000)")
 ;S ^VCORR="2" D ^VEXAMINE
 ;
4 S ^ABSN="40381",^ITEM="IV-381  subscript is a string"
 S ^NEXT="5^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
 S ^VCOMP=$QL("^V("""_A_""",""1234"")")
 S ^VCORR="2" D ^VEXAMINE
 ;
5 S ^ABSN="40382",^ITEM="IV-382  subscript are strings"
 S ^NEXT="6^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="""A;SJDAJWHRJHASLJFHLAJKSHDLKJAHLSKDHLKAS""",B="""'"""
 S ^VCOMP=$QL("^V("_A_","_B_")")
 S ^VCORR="2" D ^VEXAMINE
 ;
6 S ^ABSN="40383",^ITEM="IV-383  5 subscripts"
 S ^NEXT="7^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V="vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",B="B",C="c",D="D",E="e"
 S ^VCOMP=$QL($NA(^V(^V,B,C,D,E)))
 S ^VCORR="5" D ^VEXAMINE K ^V
 ;
 ;
7 S ^ABSN="40384",^ITEM="IV-384  namevalue contains an operator"
 S ^NEXT="8^V4QLEN6,V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="12E1"
 S ^VCOMP=$ql("^V("_-A_","_+A_")")
 S ^VCORR="2" D ^VEXAMINE
 ;
8 S ^ABSN="40385",^ITEM="IV-385  namevalue contains operators"
 S ^NEXT="V4QLEN7^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="^V",B="(1,2,3,4,5,6,7,8,9,"
 S ^VCOMP=$ql(A_B_-A_")")
 S ^VCORR="10" D ^VEXAMINE
 ;
END W !!,"End of 51 --- V4QLEN6",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
