V4QLEN3 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"48---V4QLEN3:  $QLENGTH function  -3-"
 ;
1 S ^ABSN="40354",^ITEM="IV-354  namevalue contains an operator"
 S ^NEXT="2^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 K NAME,SUB S NAME="VV(123,456,",SUB="456,789)"
 S ^VCOMP=$ql(NAME_SUB) K NAME,SUB
 S ^VCORR="4" D ^VEXAMINE
 ;
2 S ^ABSN="40355",^ITEM="IV-355  namevalue contains operators"
 S ^NEXT="3^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 k VV s VV(1,2,3)="V(0)"
 S ^VCOMP=$QL("CC("_'0_1_")")
 S ^VCORR="1" D ^VEXAMINE
 ;
3 S ^ABSN="40356",^ITEM="IV-356  namevalue contains a function"
 S ^NEXT="4^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^VCOMP=$QL($C(66,67)_"("_123_")")
 S ^VCORR="1" D ^VEXAMINE
 ;
 W !!,"namevalue contains functions"
 ;
4 S ^ABSN="40357",^ITEM="IV-357  namevalue contains $GET function"
 S ^NEXT="5^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A(2)="A(3,3,4,1)"
 S ^VCOMP=$QL($G(A(2)))
 S ^VCORR="4" D ^VEXAMINE
 ;
5 S ^ABSN="40358",^ITEM="IV-358  namevalue contains $ORDER function"
 S ^NEXT="6^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A("BB")=""
 S ^VCOMP=$ql($O(A("")))
 S ^VCORR="0" D ^VEXAMINE
 ;
6 S ^ABSN="40359",^ITEM="IV-359  namevalue contains $QUERY function"
 S ^NEXT="7^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A("BB")=""
 S ^VCOMP=$ql($q(A("")))
 S ^VCORR="1" D ^VEXAMINE
 ;
7 S ^ABSN="40360",^ITEM="IV-360  namevalue contains $SELECT function"
 S ^NEXT="8^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S Z=0
 S ^VCOMP=$ql($S(Z="A":"DD",Z="B":"A(1)",1:"A(""A"")"))
 S ^VCORR="1" D ^VEXAMINE
 ;
8 S ^ABSN="40361",^ITEM="IV-361  namevalue contains $QLENGTH function"
 S ^NEXT="9^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^VCOMP=$QL("A("_$QL("A(1,2,3,4,5)")_")")
 S ^VCORR="1" D ^VEXAMINE
 ;
9 S ^ABSN="40362",^ITEM="IV-362  namevalue contains extrinsic special variable"
 S ^NEXT="10^V4QLEN3,V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^VCOMP=$QL($$NAME)
 S ^VCORR="4" D ^VEXAMINE
 ;
10 S ^ABSN="40363",^ITEM="IV-363  namevalue contains extrinsic functions"
 S ^NEXT="V4QLEN4^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A(1,2)="CC(""C"",""D"")"
 S ^VCOMP=$QL($$F(1,2))
 S ^VCORR="2" D ^VEXAMINE
 ;
END W !!,"End of 48 --- V4QLEN3",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
NAME() Q $NA(A(1,2,"A","B"))
 ;
F(X,Y) ;
 Q A(X,Y)
