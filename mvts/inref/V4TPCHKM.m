V4TPCHKM ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 S V="#M"
 S V=V_$G(^VA)_$g(^VA(1))_$g(^VA(1,2))_$g(^VA(2))
 S V=V_$G(^VB)_$g(^VB(1))_$g(^VB(1,2))_$g(^VB(2))
 S V=V_$G(^VC)_$g(^VC(1))_$g(^VC(1,2))_$g(^VC(2))
 S V=V_$G(^VD)_$g(^VD(1))_$g(^VD(1,2))_$g(^VD(2))
 S V=V_$G(VA)_$g(VA(1))_$g(VA(1,2))_$g(VA(2))
 S V=V_$G(VB)_$g(VB(1))_$g(VB(1,2))_$g(VB(2))
 S V=V_$G(VC)_$g(VC(1))_$g(VC(1,2))_$g(VC(2))
 S V=V_$G(VD)_$g(VD(1))_$g(VD(1,2))_$g(VD(2))
 S V=V_$TLEVEL_$TRESTART_"/"
 ;IF $L(V)>250 Q
 D V4COMPM(V) ;
 IF $D(^HALT)=1 LOCK
 Q
 ;
V4COMPM(V) ;
 ;PUT COMPUTEED DATA
 LOCK +^VCOMP
 S I=$O(^VCOMP("M",""))+1
 S ^VCOMP("M",I)=V
 LOCK -^VCOMP
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
