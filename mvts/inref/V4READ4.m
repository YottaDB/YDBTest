V4READ4 ;IW-KO-YS-TS,V4READ,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"96---V4READ4:  READ Command  -4-"
 ;
 W !!,"READ *gvn"
K ;
1 W !!,"IV-623  READ *gvn"
 S ^ABSN="40623",^ITEM="IV-623  READ *gvn"
 S ^NEXT="2^V4READ4,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"   R *^VV(""M"") : Type 1 character 'M'  : ",*^VV("M")
 S ^VCOMP=^VV("M"),^VCORR="77"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G K
 D ^VEXAMINE
L ;
2 W !!,"IV-624  READ *gvn timeout"
 S ^ABSN="40624",^ITEM="IV-624  READ *gvn timeout"
 S ^NEXT="3^V4READ4,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 I 0
 R !!,"   R *^VV:60  ;Type 1 character 'A' within 60 seconds ",!,"               and NEVER touch <CR> : ",*^VV:60
 S ^VCOMP=^VV_" "_$T,^VCORR="65 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G L
 D ^VEXAMINE K ^VV
M ;
3 W !!,"IV-625  readargument contains an indirection"
 S ^ABSN="40625",^ITEM="IV-625  readargument contains an indirection"
 S ^NEXT="4^V4READ4,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 S ^VV(1)="^VV(2)"
 R !!,"   R *@^VV(1) : Type 1 character 'B' : ",*@^VV(1)
 S ^VCOMP=^VV(1)_^VV(2),^VCORR="^VV(2)66"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G M
 D ^VEXAMINE K ^VV
N ;
4 W !!,"IV-626  readargument contains indirections"
 S ^ABSN="40626",^ITEM="IV-626  readargument contains indirections"
 S ^NEXT="V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 S ^VV="^VV(1,2)",^VV(1,2,3)="^VV(4)",^VV(4)="^VV(4,5)"
 R !!,"   R *@@^VV@(3) : Type 1 character 'C' : ",*@@@^VV@(3)
 S ^VCOMP=^VV(4,5),^VCORR="67"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G N
 D ^VEXAMINE K ^VV
 ;
END W !!,"End of 96 --- V4READ4",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
