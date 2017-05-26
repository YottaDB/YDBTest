V4QSUB8 ;IW-KO-YS-TS,V4QSUB,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"61---V4QSUB8:  $QSUBSCRIPT function  -8-"
 ;
1 S ^ABSN="40449",^ITEM="IV-449  namevalue contains $NAME function"
 S ^NEXT="2^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S C=123,D="d",E="0094"
 S A="B(9)",B(9)="B(C,D,E)",ZZ="X",X=3
 S ^VCOMP=$QS($NAME(@@A),@ZZ)
 S ^VCORR="0094" D ^VEXAMINE
 ;
2 S ^ABSN="40450",^ITEM="IV-450  namevalue contains $QLENGTH function"
 S ^NEXT="3^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S B="Q(1,2,3)",Z(3)="I9(784,""B"")"
 S ^VCOMP=$QS(Z($QL(B)),0)
 S ^VCORR="I9" D ^VEXAMINE
 ;
3 S ^ABSN="40451",^ITEM="IV-451  namevalue contains $QSUBSCRIPT function"
 S ^NEXT="4^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S B="B1",B1="C(234,""#"",-345.03,345)",AB("#")="ZZZZZZ(""0.0234"",""1234"")"
 S ^VCOMP=$QS(AB($QS(@B,2)),1)
 S ^VCORR="0.0234" D ^VEXAMINE
 ;
4 S ^ABSN="40452",^ITEM="IV-452  namevalue contains extrinsic special variable"
 S ^NEXT="5^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$QS($$ABC,0)
 S ^VCORR="%000000" D ^VEXAMINE
 ;
5 S ^ABSN="40453",^ITEM="IV-453  namevalue contains extrinsic function"
 S ^NEXT="6^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S D="DDD"
 S ^VCOMP=$QS($$ZZZ(123,.D),1)
 S ^VCORR="123" D ^VEXAMINE
 ;
6 S ^ABSN="40454",^ITEM="IV-454  one subscript of a local variable has maximum length"
 S ^NEXT="7^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S A="#############################################################################################################################################################################################################################################"
 S ^VCOMP=$QS("V("""_A_""")",1)
 S ^VCORR="#############################################################################################################################################################################################################################################"
 D ^VEXAMINE
 ;
7 S ^ABSN="40455",^ITEM="IV-455  a local variable has maximum total length"
 S ^NEXT="8^V4QSUB8,V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$QS($NA(V(A,A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,"ABCDEFG")),19)
 S ^VCORR="ABCDEFG" D ^VEXAMINE
 ;
8 S ^ABSN="40456",^ITEM="IV-456  minimum to maximum number of one subscript of a local variable"
 S ^NEXT="V4QSUB9^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S ^VCOMP=$qs("A(-10000000000000000000000000,10000000000000000000000000,-.0000000000000000000000001,-.0000000000000000000000001)",2)
 S ^VCORR="10000000000000000000000000" D ^VEXAMINE
 ;
END W !!,"End of 61 --- V4QSUB8",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
ABC() Q "%000000(0,""#"")"
 ;
ZZZ(%1,%2) ;
 Q $NAME(@%2@(%1))
 ;
