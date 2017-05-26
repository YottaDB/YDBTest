V4QUIT ;IW-KO-YS-TS,VV4,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"120---V4QUIT:  QUIT @expratom"
 ;
1 S ^ABSN="40747",^ITEM="IV-747  return to an exvar"
 S ^NEXT="2^V4QUIT,V4MAX^VV4" D ^V4PRESET K
 S AB(1)="V(""B"",4,5)",V("B",4,5)="OK"
 S ^VCOMP=$$ABCD
 S ^VCORR="OK" D ^VEXAMINE
 ;
2 S ^ABSN="40748",^ITEM="IV-748  return to an exfunc"
 S ^NEXT="3^V4QUIT,V4MAX^VV4" D ^V4PRESET K  K ^V
 S V="^V"
 S ^V(1,2,3)="xyz"
 S ^VCOMP=$$XXF(1,2)
 S ^VCORR="xyz" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40749",^ITEM="IV-749  expratom has a lvn"
 S ^NEXT="4^V4QUIT,V4MAX^VV4" D ^V4PRESET K
 S A(1,2)="B(1,2)",B(1,2)="XXXX"
 S ^VCOMP=$$A1^V4QUITE
 S ^VCORR="XXXX" D ^VEXAMINE
 ;
4 S ^ABSN="40750",^ITEM="IV-750  expratom has a gvn"
 S ^NEXT="5^V4QUIT,V4MAX^VV4" D ^V4PRESET K  K ^V
 S ^V(3,4,5)="V345",^V(3,4)="V34",^V(3)="V3",^V="V"
 S ^VCOMP=$$F2("^V(3,4,5)",2)
 S ^VCORR="V34" D ^VEXAMINE K ^V
 ;
5 S ^ABSN="40751",^ITEM="IV-751  expratom contains a naked reference"
 S ^NEXT="6^V4QUIT,V4MAX^VV4" D ^V4PRESET K
 S ^V(1,2,1)=121,^V(1,1)=11,^V(1,2,3)=2
 S ^V(1,2)=12
 S ^VCOMP=$$F3(^(2,3))
 S ^VCORR="12" D ^VEXAMINE
 ;
6 S ^ABSN="40752",^ITEM="IV-752  nasting indirection"
 S ^NEXT="V4MAX^VV4" D ^V4PRESET K
 S A=2
 S ^VCOMP=$$F4^V4QUITE("V",.A,3)
 S ^VCORR="AA" D ^VEXAMINE
 ;
END W !!,"End of 120 --- V4QUIT",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
ABCD() Q @AB(1)
XXF(X,Y) ;
 S Z=X+Y
 Q @V@(X,Y,Z)
F2(X,Y) ;
 Q @$NA(@X,Y)
F3(X) Q @$NA(^(1),X)
