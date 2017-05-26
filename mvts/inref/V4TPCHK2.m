V4TPCHK2 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 new mjname
 S V="#2"
 S V=V_$G(^VA)_$g(^VA(1))_$g(^VA(1,2))_$g(^VA(2))
 S V=V_$G(^VB)_$g(^VB(1))_$g(^VB(1,2))_$g(^VB(2))
 S V=V_$G(^VC)_$g(^VC(1))_$g(^VC(1,2))_$g(^VC(2))
 S V=V_$G(^VD)_$g(^VD(1))_$g(^VD(1,2))_$g(^VD(2))
 S V=V_$G(VA)_$g(VA(1))_$g(VA(1,2))_$g(VA(2))
 S V=V_$G(VB)_$g(VB(1))_$g(VB(1,2))_$g(VB(2))
 S V=V_$G(VC)_$g(VC(1))_$g(VC(1,2))_$g(VC(2))
 S V=V_$G(VD)_$g(VD(1))_$g(VD(1,2))_$g(VD(2))
 S V=V_$TLEVEL_$TRESTART_"/"
 ;IF $L(V)>250 HALT
 set mjname=$translate($STACK($stack(-1)-1,"PLACE"),"+^","__")
 set xstr="JOB ^V4COMP2(V):(output="""_mjname_".mjo"":error="""_mjname_".mje""):120"
 write xstr,!
 xecute xstr  ELSE  ZSHOW "*":^V4COMP1ERROR($J) HALT
 do ^waitforproctodie($zjob)	; wait for jobbed off process to terminate before releasing locks
 IF $D(^HALT)=1 LOCK  HALT
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
