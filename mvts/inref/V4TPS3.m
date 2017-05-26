V4TPS3 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 S ^VA(1)=$g(^VA(1))_"^VA(1)"
 S ^VB(1,2)=$g(^VB(1,2))_"^VB(1,2)"
 S ^VC(2)=$g(^VC(2))_"^VC(2)"
 S ^VD(1,2)=$g(^VD(1,2))_"^VD(1,2)"
 S VA(1)=$g(VA(1))_"VA(1)"
 S VB(1,2)=$g(VB(1,2))_"VB(1,2)"
 S VC(2)=$g(VC(2))_"VC(2)"
 S VD(1,2)=$g(VD(1,2))_"VD(1,2)"
 Q
 ;^VA(1)^VB(1,2)^VC(2)^VD(1,2)VA(1)VB(1,2)VC(2)VD(1,2)
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
