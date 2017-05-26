V4ORD26 ;IW-KO-TS-YS,V4ORDER,MVTS V9.10;15/6/96;$ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 W !!,"113---V4ORD26:  $ORDER(glvn,expr)  -6-"
 ;
 W !,"expr contains a function"
 ;
1 S ^ABSN="40712",^ITEM="IV-712  expr contains $GET function"
 S ^NEXT="2^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^V("B",-111)=-1,^V("A",1,12)=12,^V("A",1,"HHH")="hhh"
 S ^V("B",1)="OK",^V("A",1)="ERROR2",^V("AA",1,1)="ERROR1",^V("A",1,1)="ERROR3"
 S ^VCOMP=$o(^V("A",1,""),$G(^V("AA",2),^V("B",-111)))_" "_^(1)
 S ^VCORR="HHH OK" D ^VEXAMINE K ^V
 ;
2 S ^ABSN="40713",^ITEM="IV-713  expr contains $ORDER function"
 S ^NEXT="3^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^V("B",-111)=-1,^V("A",1,12)=12,^V("A",1,"HHH")="hhh"
 S ^V("C",1)=111,^V("A",1,1)="ERROR0"
 S ^V("B",1)="OK",^V("A",1)="ERROR2",^V("AA",1,1)="ERROR1"
 S ^VCOMP=$o(^V("A",1,2),$O(^V("C",2),^V("B",-111)))_" "_^(1)
 S ^VCORR="12 OK" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40714",^ITEM="IV-714  expr contains $SELECT function"
 S ^NEXT="4^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  k ^V
 s ^V("99990.00")="",A=0
 S ^VCOMP=$o(^V(""),$S(A=1:1,1:-1))
 S ^VCORR="99990.00" D ^VEXAMINE k ^V
 ;
4 S ^ABSN="40715",^ITEM="IV-715  expr contains extrinsic special variable"
 S ^NEXT="5^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S ^VCOMP=$O(V(2,-1),$$ABC)
 S ^VCORR="2" D ^VEXAMINE
 ;
5 S ^ABSN="40716",^ITEM="IV-716  expr contains extrinsic function"
 S ^NEXT="6^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^V(2)=2,^V(1,1,"A")="a",^V(1,1,2)="AA"
 S ^VCOMP=$O(^V(1,1,2),$$A^V4ORDE(1,^V(2)))_" "_Z_" "_^(2)
 S ^VCORR="A 12 2" D ^VEXAMINE K ^V
 ;
 W !,"expr contains a operator"
 ;
6 S ^ABSN="40717",^ITEM="IV-717  expr contains a + operator"
 S ^NEXT="7^V4ORD26,V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S V(1,"A","Z")=1,V(2,"AAA")=2,V(1,-93943,12)=3
 S ^VCOMP=$O(V(1,""),64784-64785)
 S ^VCORR="A" D ^VEXAMINE
 ;
7 S ^ABSN="40718",^ITEM="IV-718  expr contains a ? operator"
 S ^NEXT="V4ORD27^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S X="123ABCDEE3GH4G3343",V("A","B",9999)=12,V("A","B","123","zzz",123)=12
 S ^VCOMP=$o(V("A","B",123,456),X?2.5N2.AN2N)
 S ^VCORR="zzz" D ^VEXAMINE
 ;
END W !!,"End of 113 --- V4ORD26",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
ABC() S V(2,2)=1
 q 1
