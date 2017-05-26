V4QSUB7 ;IW-KO-YS-TS,V4QSUB,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"60---V4QSUB7:  $QSUBSCRIPT function  -7-"
 ;
1 S ^ABSN="40440",^ITEM="IV-440  namevalue contains lvn"
 S ^NEXT="2^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 s NAME="ABCDE(""abcd"",1234.456)"
 S ^VCOMP=$QS(NAME,1)
 S ^VCORR="abcd" D ^VEXAMINE
 ;
; **MVTS LOCAL CHANGE**
; non-canonical value for $QS - 10/2001 SE
2 ;S ^ABSN="40441",^ITEM="IV-441  namevalue contains gvn"
 ;S ^NEXT="3^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 ;S ^V(1)=123
 ;S V(123,456)="V12345(^V(1),456)"
 ;S ^VCOMP=$QS(V(123,456),0)
 ;S ^VCORR="V12345" D ^VEXAMINE k ^V
 ;
3 S ^ABSN="40442",^ITEM="IV-442  namevalue contains operators"
 S ^NEXT="4^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S A(1)="BCDFGH9(""####"",""$$$$$"")"
 S ^VCOMP=$qs(A('0),1)
 S ^VCORR="####" D ^VEXAMINE
 ;
4 S ^ABSN="40443",^ITEM="IV-443  namevalue contains naked refernce"
 S ^NEXT="5^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K  K ^V
 S ^V(1,2,3)="V12345(11,22,33,44,55)",^V(1,2,2)=0,^V(1,2)=2
 S ^VCOMP=$QS(^(2,3),^(2))_" "_^(2)
 S ^VCORR="V12345 0" D ^VEXAMINE K ^V
 ;
5 S ^ABSN="40444",^ITEM="IV-444  namevalue has indirections"
 S ^NEXT="6^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S NAME="@B(1)@(""A"",3)",B(1)="BCD(""Z"",""E"",""R"")",A=4
 s BCD("Z","E","R","A",3)="JHDUI(""P"",""DJD"",""PDJD"",""JDHFK"")"
 S ^VCOMP=$QS(@NAME,A)
 S ^VCORR="JDHFK" D ^VEXAMINE
 ;
 W !!,"namevalue contains functions"
 ;
6 S ^ABSN="40445",^ITEM="IV-445  namevalue contains $GET function"
 S ^NEXT="7^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S A(2)="XYZ123(1,2,3)"
 S ^VCOMP=$QS($G(A(2)),+$G(A(1)))
 S ^VCORR="XYZ123" D ^VEXAMINE
 ;
7 S ^ABSN="40446",^ITEM="IV-446  namevalue contains $ORDER function"
 S ^NEXT="8^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S Z("Z(0,2,""#"")")=1
 S ^VCOMP=$qs($O(Z(0)),3)
 S ^VCORR="#" D ^VEXAMINE
 ;
8 S ^ABSN="40447",^ITEM="IV-447  namevalue contains $QUERY function"
 S ^NEXT="9^V4QSUB7,V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S H(1,2,"^^^^")=1
 S ^VCOMP=$QS($Q(H),2)
 S ^VCORR="2" D ^VEXAMINE
 ;
9 S ^ABSN="40448",^ITEM="IV-448  namevalue contains $SELECT function"
 S ^NEXT="V4QSUB8^V4QSUB,V4SVQ^VV4" D ^V4PRESET K
 S A="D",D=0
 S ^VCOMP=$qs($s(@A:B,1:"%123(0,1,2,3)"),D)
 S ^VCORR="%123" D ^VEXAMINE
 ;
END W !!,"End of 60 --- V4QSUB7",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
