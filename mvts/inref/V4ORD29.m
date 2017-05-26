V4ORD29 ;IW-KO-TS-YS,V4ORDER,MVTS V9.10;15/6/96;$ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 W !!,"116---V4ORD29:  $ORDER(glvn,expr)  -9-"
 ;
 W !,"glvn contains a function"
 ;
1 S ^ABSN="40730",^ITEM="IV-730  glvn contains $GET function"
 S ^NEXT="2^V4ORD29,V4ORD2A^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S ABC(1)="A",B=23,A("A","B")="",A("A",-0,45.67)=""
 S ^VCOMP=$O(A($GET(ABC(1)),$g(A,B)),-1)
 S ^VCORR="0" D ^VEXAMINE
 ;
2 S ^ABSN="40731",^ITEM="IV-731  glvn contains $ORDER function"
 S ^NEXT="3^V4ORD29,V4ORD2A^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S A(0,1)="",A("B(45,-2)",-1)="",B(45,"ok")="",B="b",B(1)="1"
 S ^VCOMP=$O(@$o(A(0),1),$O(A(0,0)))
 S ^VCORR="ok" D ^VEXAMINE
 ;
3 S ^ABSN="40732",^ITEM="IV-732  glvn contains $SELECT function"
 S ^NEXT="4^V4ORD29,V4ORD2A^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S A="a",C="A(1,""FG"",1)",A(1,"FG",-23)="",A(1,"FG","-456.0010")=1
 S ^VCOMP=$O(@$S(A="A":B,1:C),1.0000)
 S ^VCORR="-456.0010" D ^VEXAMINE
 ;
4 S ^ABSN="40733",^ITEM="IV-733  glvn contains extrinsic special variable"
 S ^NEXT="5^V4ORD29,V4ORD2A^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S A(2)="A(100)",A(100)=1,X="12000"
 S ^VCOMP=$o(@$$XXXX,@A(2))
 S ^VCORR="ABCDEFG" D ^VEXAMINE
 ;
5 S ^ABSN="40734",^ITEM="IV-734  glvn contains extrinsic function"
 S ^NEXT="V4ORD2A^V4ORDER,V4QUERY^VV4" D ^V4PRESET K
 S ^VCOMP=$o(V(1,$$YY(1,2,2),$$YY(1,2,"a")),-1)
 S ^VCORR="2" D ^VEXAMINE
 ;
END W !!,"End of 116 --- V4ORD29",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
XXXX() ;
 N X
 S V("J",90,12)=12,V("J",90,"ABCDEFG",12345)=12
 S X="V(""J"",90,X)"
 Q X
YY(X,Y,Z) ;
 S V(X,Y,Z)=""
 Q Z
