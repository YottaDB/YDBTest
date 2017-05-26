V4SYSJOB ;IW-KO-YS-TS,V4SYSTEM,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;(test fixed in V9.02;7/10/95)
 ;
 S ^VV="error"
 S ^VV=($SYSTEM?1.N1","1.E)_($system?1.N1","1.E)_($SYSTEM=$system)_" "
 S ^VV=^VV_($SY?1.N1","1.E)_($sy?1.N1","1.E)_($SY=$sy)_($SYSTEM=$SY)
 S ^VV=^VV_"/"_$SYSTEM
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
