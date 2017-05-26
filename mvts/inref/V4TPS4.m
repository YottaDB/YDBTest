V4TPS4 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 S ^VA(1)=$g(^VA(1))_"^va(1)"
 S ^VB(2)=$g(^VB(2))_"^vb(2)"
 S ^VC(1,2)=$g(^VC(1,2))_"^vc(1,2)"
 S ^VD(2)=$g(^VD(2))_"^vd(2)"
 S VA(1)=$g(VA(1))_"va(1)"
 S VB(2)=$g(VB(2))_"vb(2)"
 S VC(1,2)=$g(VC(1,2))_"vc(1,2)"
 S VD(2)=$g(VD(2))_"vd(2)"
 Q
 ;^va(1)^vb(2)^vc(1,2)^vd(2)va(1)vb(2)vc(1,2)vd(2)
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
