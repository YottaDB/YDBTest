V4PRETP3 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;preset for 3 Transactions test
 S ^VREPORT("Part-94",^ABSN)="*ABORT*"
 S ^VREPORT("Part-94",^ABSN,"ITEM")=^ITEM
 S ^VREPORT("Part-94",^ABSN,"NEXT")=^NEXT
 K ^VA,^VB,^VC,^VD,^VCOMP,^VS
 LOCK
 S ^VCOMP=""
 S ^VS(1)=1,^VS(2)=1,^VS(3)=1
 K
 S WAIT=""
 LOCK +^V(3),+^V(2),+^V(1)
 K ^HALT
TINIT ;------------------------------------------
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
