V3ESVE ;IW-KO-YS-TS,V3ESV,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
00001() S A="A",B="B",C="C" K A N B
 Q "OK"
000010() S A="A",B="B",C="C",D="D" N (A,B) K (B) I 1
 S A="a",B="b",C="c",D="d"
 Q "OK"
T() S A="A",B="B",C="C" K A N B I 0
 Q "OK"
