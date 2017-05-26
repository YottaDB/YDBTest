V4QLEN8 ;IW-KO-YS-TS,V4QLEN,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"53---V4QLEN8:  $QLENGTH function  -8-"
 ;
1 S ^ABSN="40393",^ITEM="IV-393  namevalue has indirection"
 S ^NEXT="2^V4QLEN8,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V(1,2)="^V(""A"",""B"")",^V("A","B",5,6)="^V(0,0,0,0,0)"
 S ^VCOMP=$QL(@^V(1,2)@(5,6))
 S ^VCORR="5" D ^VEXAMINE
 ;
2 S ^ABSN="40394",^ITEM="IV-394  namevalue contains a naked refernce"
 S ^NEXT="3^V4QLEN8,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V(2,2)=22,^V(2)=2,^V(22)="^V(1,2,3,4,2)"
 S ^VCOMP=$QL("^V("_^(2,2)_")")_" "_^(2)
 S ^VCORR="1 22" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40395",^ITEM="IV-395  namevalue contains naked refernces"
 S ^NEXT="4^V4QLEN8,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S ^V(2,2)="C(1,2)",^V(2)=2,C(1,2,2)="^V(1,2,3,4,2)"
 S ^VCOMP=$QL(@^(2,2)@(^V(2)))_" "_^(2)
 S ^VCORR="5 2" D ^VEXAMINE
 ;
4 S ^ABSN="40396",^ITEM="IV-396  one subscript of a global variable has maximum length"
 S ^NEXT="5^V4QLEN8,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="""#############################################################################################################################################################################################################################################"""
 S ^VCOMP=$QL("^V("_A_")")
 S ^VCORR="1" D ^VEXAMINE
 ;
5 S ^ABSN="40397",^ITEM="IV-397  a global variable has maximum total length"
 S ^NEXT="6^V4QLEN8,V4QSUB^VV4" D ^V4PRESET K  K ^V
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$QL($NA(^V(A,A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,"ABCDEFG")))
 S ^VCORR="19" D ^VEXAMINE
 ;
6 S ^ABSN="40398",^ITEM="IV-398  minimum to maximum number of one subscript of a global variable"
 S ^NEXT="V4QSUB^VV4" D ^V4PRESET K  k ^V
 S ^VCOMP=$ql("^V(-10000000000000000000000000,10000000000000000000000000,-.0000000000000000000000001,-.0000000000000000000000001)")
 S ^VCORR="4" D ^VEXAMINE k ^V
 ;
END W !!,"End of 53 --- V4QLEN8",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
