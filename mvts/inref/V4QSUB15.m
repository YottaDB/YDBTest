V4QSUB15 ;IW-KO-YS-TS,V4QSUB,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"68---V4QSUB15:  $QSUBSCRIPT function  -15-"
 ;
1 S ^ABSN="40507",^ITEM="IV-507  namevalue contains $NAME function"
 S ^NEXT="2^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K
 S N=2,A="0000.0003283",B="-00083.383000",C="030303000.000",D="###"
 S ^VCOMP=$qs($NAME(^V(+A,+B,+C,D)),N)
 S ^VCORR="-83.383" D ^VEXAMINE
 ;
2 S ^ABSN="40508",^ITEM="IV-508  namevalue contains $QLENGTH function"
 S ^NEXT="3^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K
 S ^V(1,1)="^V1234567(0,0,0,123)"
 S ^VCOMP=$QS(^V(1,$QL("A(1)")),0)
 S ^VCORR="^V1234567" D ^VEXAMINE
 ;
3 S ^ABSN="40509",^ITEM="IV-509  namevalue contains $QSUBSCRIPT function"
 S ^NEXT="4^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K  K ^V
 S A="B(123,""0.00002300"")",^V(.000023)="^V(""000,0000"",""38484,3939"")"
 S ^VCOMP=$QS(^V(+$QS(A,2)),1)
 S ^VCORR="000,0000" D ^VEXAMINE K ^V
 ;
4 S ^ABSN="40510",^ITEM="IV-510  namevalue contains extrinsic special variable"
 S ^NEXT="5^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$QS($$NA,$$ARG)
 S ^VCORR="-0000000202" D ^VEXAMINE
 ;
5 S ^ABSN="40511",^ITEM="IV-511  namevalue contains extrinsic function"
 S ^NEXT="6^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qs($$NAME("^V12345","0000","003094.02",1),0)
 S ^VCORR="^V12345" D ^VEXAMINE
 ;
6 S ^ABSN="40512",^ITEM="IV-512  one subscript of global variable has maximum length"
 S ^NEXT="7^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K  k ^V
 S ^V("#############################################################################################################################################################################################################################################")=""
 S ^VCOMP=$QS($Q(^V),1)
 S ^VCORR="#############################################################################################################################################################################################################################################"
 D ^VEXAMINE K ^V
 ;
7 S ^ABSN="40513",^ITEM="IV-513  a global variable has maximum total length"
 S ^NEXT="8^V4QSUB15,V4SVQ^VV4" D ^V4PRESET K
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$QS($NA(^V(A,A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,"ABCDEFG")),10)
 S ^VCORR="1234567890" D ^VEXAMINE
 ;
8 S ^ABSN="40514",^ITEM="IV-514  minimum to maximum number of one subscript of a global variable"
 S ^NEXT="V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qs("^V(-10000000000000000000000000,10000000000000000000000000,-.0000000000000000000000001,-.0000000000000000000000001)",3)
 S ^VCORR="-.0000000000000000000000001" D ^VEXAMINE
 ;
END W !!,"End of 68 --- V4QSUB15",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
NA() Q "^V(123,""-0000000202"",234)"
ARG() Q 2
 ;
NAME(X,Y,Z,W) ;
 Q $NAME(@X@(Y,Z,W))
 ;
