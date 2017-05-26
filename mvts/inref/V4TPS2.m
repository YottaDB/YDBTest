V4TPS2 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 S ^VA=$g(^VA)_"^va"
 S ^VB(1)=$g(^VB(1))_"^vb(1)"
 K ^VC,^VD
 S VA=$g(VA)_"va"
 S VB(1)=$g(VB(1))_"vb(1)"
 K VC,VD
 Q
 ;^va^vb(1)vavb(1)
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
