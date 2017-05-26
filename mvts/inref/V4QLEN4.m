V4QLEN4 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"49---V4QLEN4:  $QLENGTH function  -4-"
 ;
1 S ^ABSN="40364",^ITEM="IV-364  namevalue has indirection"
 S ^NEXT="2^V4QLEN4,V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="@B@(1,2)",B="C(1,2,3)",C(1,2,3,1,2)="A(1,2,3,4,5,6,7)"
 S ^VCOMP=$QL(@A)
 S ^VCORR="7" D ^VEXAMINE
 ;
2 S ^ABSN="40365",^ITEM="IV-365  namevalue contains a naked refernce"
 S ^NEXT="3^V4QLEN4,V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^V(2,2)=22,^V(2)=2,A(22)="A(22)"
 S ^VCOMP=$QL("A("_^(2,2)_")")_" "_^(2)
 S ^VCORR="1 22" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40366",^ITEM="IV-366  namevalue contains naked refernces"
 S ^NEXT="4^V4QLEN4,V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^V(2,2)="C(1,2)",^V(2)=2,C(1,2,2)="A(1)"
 S ^VCOMP=$QL(@^(2,2)@(^V(2)))_" "_^(2)
 S ^VCORR="1 2" D ^VEXAMINE
 ;
4 S ^ABSN="40367",^ITEM="IV-367  one subscript of a global variable has maximum length"
 S ^NEXT="5^V4QLEN4,V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A="#############################################################################################################################################################################################################################################"
 S ^VCOMP=$QL("V("""_A_""")")
 S ^VCORR="1" D ^VEXAMINE
 ;
5 S ^ABSN="40368",^ITEM="IV-368  a local variable has maximum total length"
 S ^NEXT="6^V4QLEN4,V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$QL($NA(V(A,A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,"ABCDEFG")))
 S ^VCORR="19" D ^VEXAMINE
 ;
6 S ^ABSN="40369",^ITEM="IV-369  minimum to maximum number of one subscript of a local variable"
 S ^NEXT="V4QLEN5^V4QLEN,V4QSUB^VV4" D ^V4PRESET K
 S ^VCOMP=$ql("A(-10000000000000000000000000,10000000000000000000000000,-.0000000000000000000000001,-.0000000000000000000000001)")
 S ^VCORR="4" D ^VEXAMINE
 ;
END W !!,"End of 49 --- V4QLEN4",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
