V4TPE11 ;IW-KO-YS-TS,VV4TP,MVTS V9.10;15/7/96;PART-94 Transaction
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
1 ;---$TLEVEL and $TRESTART
 F  Q:$$^V4GETS1
 S V=""
 S V=V_$TLEVEL_" "_$TL
 S V=V_"/"_$TRESTART_" "_$TR
 S V=V_"/"_$tlevel_" "_$tl
 S V=V_"/"_$trestart_" "_$tr
 JOB ^V4COMP1(V) ;
 do ^waitforproctodie($zjob)	; wait for jobbed off process to terminate before releasing locks
 L  H
 ;
2 ;---TSTART ... TCOMMIT
 F  Q:$$^V4GETS1
 TSTART
 D ^V4TPS1
 D ^V4TPCHK
 TCOMMIT
 D ^V4TPCHK
 L  H
 ;
3 ;---TSTART ... TROLLBACK
 F  Q:$$^V4GETS1
 TSTART
 D ^V4TPS1
 D ^V4TPCHK
 TROLLBACK
 D ^V4TPCHK
 L  H
 ;
4 ;---TSTART ... HALT
 F  Q:$$^V4GETS1
 TSTART
 D ^V4TPS1
 D ^V4TPCHK
 L
 HALT
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
