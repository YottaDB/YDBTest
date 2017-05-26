V4READ2 ;IW-KO-YS-TS,V4READ,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"94---V4READ2:  READ Command  -2-"
 ;
D ;
1 W !!,"IV-616  $D(gvn)=10"
 S ^ABSN="40616",^ITEM="IV-616  $D(gvn)=10"
 S ^NEXT="2^V4READ2,V4READ3^V4READ,V4KEY^VV4" D ^V4PRESET K  K ^VV
 S ^VV(1,2,3,4,5)=12345
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"   READ ^VV(1,2) : Type only a <CR> : ",^VV(1,2)
 S ^VCOMP=^VV(1,2)_$D(^VV)_$D(^VV(1))_$D(^VV(1,2))_$D(^VV(1,2,3))_$Q(^VV)_$Q(^VV(1,2))_$Q(^VV(1,2,3,4,5))
 S ^VCORR="10101110^VV(1,2)^VV(1,2,3,4,5)"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G D
 D ^VEXAMINE
E ;
2 W !!,"IV-617  $D(gvn)=11"
 S ^ABSN="40617",^ITEM="IV-617  $D(gvn)=11"
 S ^NEXT="3^V4READ2,V4READ3^V4READ,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 s ^VV("data")="DATA",^VV("data",1)="001",^VV("data",2)="002"
 s ^VV("DATA")="data",^VV("DATA",3)="003",^VV("DATA",4)="004"
 r !!,"   r ^VV(""data"") : Type 10 characters '1234567890' and a <CR> : ",!,"                           ",^VV("data")
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="1234567890 10111"
 S ^VCOMP=^VV("data")_" "_$D(^VV)_$D(^VV("data"))_$D(^VV("data",1))
 D AGAIN^VEXAMINE I RES="YES" G E
 D ^VEXAMINE K ^VV
F ;
3 W !!,"IV-618  READ gvn readcount"
 S ^ABSN="40618",^ITEM="IV-618  READ gvn readcount"
 S ^NEXT="4^V4READ2,V4READ3^V4READ,V4KEY^VV4" D ^V4PRESET K  k ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 READ !,"   READ ^VV(""A"")#3  : Type 3 characters 'ABC' ",!,"                      and NEVER touch <CR> : ",^VV("A")#3
 S ^VCOMP=^VV("A")_$O(^VV("")),^VCORR="ABCA"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G F
 D ^VEXAMINE
G ;
4 W !!,"IV-619  READ gvn readcount timeout"
 S ^ABSN="40619",^ITEM="IV-619  READ gvn readcount timeout"
 S ^NEXT="V4READ3^V4READ,V4KEY^VV4" D ^V4PRESET K
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 r !,"   r ^VV(1)#3:60  : Type 3 chars 'ABC' within 60 Seconds ",!,"                    and NEVER touch <CR> : ",^VV(1)#3:60
 S ^VCOMP=^VV(1)_$T,^VCORR="ABC1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G G
 D ^VEXAMINE K ^VV
 ;
END W !!,"End of 94 --- V4READ2",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
