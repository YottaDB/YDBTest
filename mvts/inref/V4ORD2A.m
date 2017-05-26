V4ORD2A ;IW-KO-TS-YS,V4ORDER,MVTS V9.10;15/6/96;$ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 W !!,"117---V4ORD2A:  $ORDER(glvn,expr)  -10-"
 ;
 W !,"glvn contains a operator"
 ;
1 S ^ABSN="40735",^ITEM="IV-735  glvn contains a + operator"
 S ^NEXT="2^V4ORD2A,V4QUERY^VV4" D ^V4PRESET K
 S A("A",1)=1,A("A",101)=1,A("A",201)=1
 S ^VCOMP=$o(A("A",100+34),-1)
 S ^VCORR="101" D ^VEXAMINE
 ;
2 S ^ABSN="40736",^ITEM="IV-736  glvn contains a ? operator"
 S ^NEXT="3^V4ORD2A,V4QUERY^VV4" D ^V4PRESET K
 S A="JKFDJKDF9848MF832MNF83="
 S V("****")=1,V(0)=1,V(0.5)=1
 S ^VCOMP=$O(V(A?2.A3.99ANA1P),1)
 S ^VCORR="****" D ^VEXAMINE
 ;
 W !,"glvn has indirections"
 ;
3 S ^ABSN="40737",^ITEM="IV-737  ^V(@A)"
 S ^NEXT="4^V4ORD2A,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S A="^V(.001,2,3)",^V(0.001,2,3)="QQQ",^V(0.047)=1
 S ^VCOMP=$o(^V(@A),A-1)
 S ^VCORR=".047" D ^VEXAMINE K ^V
 ;
4 S ^ABSN="40738",^ITEM="IV-738  @VV"
 S ^NEXT="5^V4ORD2A,V4QUERY^VV4" D ^V4PRESET K
 S VV="A(12,3)",A(12,0)=1,A(12,"A")=1
 S ^VCOMP=$O(@VV,1)
 S ^VCORR="A" D ^VEXAMINE
 ;
5 S ^ABSN="40739",^ITEM="IV-739  @^V@(12,456)"
 S ^NEXT="6^V4ORD2A,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^V="^V(""##"")",^V("##",12,"]=_","\\\")="",A=1,^V("##",12,1)="ok"
 S ^VCOMP=$o(@^V@(12,456),A)_" "_^(1)
 S ^VCORR="]=_ ok" D ^VEXAMINE K ^V
 ;
6 S ^ABSN="40740",^ITEM="IV-740  @@^V(0)@(12,456)"
 S ^NEXT="V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^V(0)="V(1)",V(1,12,456)="^V(2,3)",^V(2,1)=21
 S ^VCOMP=$O(@@^V(0)@(12,456),$O(V("")))_" "_^(1)
 S ^VCORR=" 21" D ^VEXAMINE K ^V
 ;
END W !!,"End of 117 --- V4ORD2A",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
