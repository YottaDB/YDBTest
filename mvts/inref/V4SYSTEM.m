V4SYSTEM ;IW-KO-YS-TS,VV4,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"98---V4SYSTEM:  Special variable $SYSTEM"
 ;
1 S ^ABSN="40630",^ITEM="IV-630  $SYSTEM value format"
 S ^NEXT="2^V4SYSTEM,V4POWER^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S ^VCOMP=($SYSTEM?1.N1","1.E)_($system?1.N1","1.E)_($SYSTEM=$system)
 S ^VCORR="111" D ^VEXAMINE
 ;
2 S ^ABSN="40631",^ITEM="IV-631  $SY value format"
 S ^NEXT="3^V4SYSTEM,V4POWER^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S ^VCOMP=($SY?1.N1","1.E)_($sy?1.N1","1.E)_($SY=$sy)_($SYSTEM=$SY)
 S ^VCORR="1111" D ^VEXAMINE
 ;
3 S ^ABSN="40632",^ITEM="IV-632  $SYSTEM under another JOB"
 S ^NEXT="V4POWER^VV4" D ^V4PRESET K  K ^VV
 ;(test fixed in V9.02;7/10/95)
 job ^V4SYSJOB::10
 IF $T F I=1:1:60 Q:$D(^VV)#10=1  H 1
 H 1
 I $D(^VV)#10=0 S ^VV="ERROR"
 S ^VCOMP=$P(^VV,"/",1)_" "_($P(^VV,"/",2)=$SYSTEM)
 S ^VCORR="111 1111 1" D ^VEXAMINE
 ;
END W !!,"End of 98 --- V4SYSTEM",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
