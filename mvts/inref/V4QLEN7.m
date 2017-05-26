V4QLEN7 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"52---V4QLEN7:  $QLENGTH function  -7-"
 ;
 W !!,"namevalue contains a function"
 ;
1 S ^ABSN="40386",^ITEM="IV-386  namevalue contains $GET function"
 S ^NEXT="2^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="^V(1,""BBBBB"",""CCCCC"",0,0,0,0)"
 S ^VCOMP=$ql($G(A))
 S ^VCORR="7" D ^VEXAMINE
 ;
2 S ^ABSN="40387",^ITEM="IV-387  namevalue contains $ORDER function"
 S ^NEXT="3^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V(1,2,3)=""
 S ^VCOMP=$QL("^V(1,1,"_$O(^V(1,2,0))_")")
 S ^VCORR="3" D ^VEXAMINE
 ;
3 S ^ABSN="40388",^ITEM="IV-388  namevalue contains $QUERY function"
 S ^NEXT="4^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V(1,2,3,4,5,6)=""
 S ^VCOMP=$QL($Q(^V(1,2,0)))
 S ^VCORR="6" D ^VEXAMINE
 ;
4 S ^ABSN="40389",^ITEM="IV-389  namevalue contains $SELECT function"
 S ^NEXT="5^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S X="X",Y="Y(0,1,2,3)",Z="Z81)",A=2
 S ^VCOMP=$ql($S(A=1:X,A=2:Y,1:Z))
 S ^VCORR="4" D ^VEXAMINE
 ;
5 S ^ABSN="40390",^ITEM="IV-390  namevalue contains $QLENGTH function"
 S ^NEXT="6^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="^V(0,0,0)"
 S ^VCOMP=$QL($P("A/A(1)/A(1,2)/A(1,2,3)","/",$QL(A)))
 S ^VCORR="2" D ^VEXAMINE
 ;
6 S ^ABSN="40391",^ITEM="IV-391  namevalue contains extrinsic special variable"
 S ^NEXT="7^V4QLEN7,V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A=1234
 S ^VCOMP=$ql($$NAME1)
 S ^VCORR="1" D ^VEXAMINE
 ;
7 S ^ABSN="40392",^ITEM="IV-392  namevalue contains extrinsic functions"
 S ^NEXT="V4QLEN8^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S (X,Y,Z)="A"
 S ^VCOMP=$ql($$DATA(X,Y,Z))
 S ^VCORR="3" D ^VEXAMINE
 ;
END W !!,"End of 52 --- V4QLEN7",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
NAME1() ;
 Q "^V("_A_")"
 ;
DATA(A,B,C) ;
 Q $NAME(A(A,B,C))
