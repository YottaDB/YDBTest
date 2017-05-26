V4READ3 ;IW-KO-YS-TS,V4READ,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"95---V4READ3:  READ Command  -3-"
 ;
H ;
1 W !!,"IV-620  READ gvn timeout"
 S ^ABSN="40620",^ITEM="IV-620  READ gvn timeout"
 S ^NEXT="2^V4READ3,V4READ4^V4READ,V4KEY^VV4" D ^V4PRESET K  I 1
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"   R ^VV(1,2):10 ; Type 2 chars 'AB' within 10 seconds ",!,"                   and NEVER touch <CR> : ",^VV(1,2):10
 S ^VCOMP=^VV(1,2)_$T,^VCORR="AB0"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G H
 D ^VEXAMINE K ^VV
I ;
2 W !!,"IV-621  readargument contains an indirection"
 S ^ABSN="40621",^ITEM="IV-621  readargument contains an indirection"
 S ^NEXT="3^V4READ3,V4READ4^V4READ,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 S N=1,M=2
 S ^VV(1)="!,""   R @^VV(1) ; Type 3 characters 'abc' and a <CR> : "",^VV(M)"
 R !,@^VV(N)
 S ^VCOMP=^VV(2),^VCORR="abc"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G I
 D ^VEXAMINE
J ;
3 W !!,"IV-622  readargument contains indirections"
 S ^ABSN="40622",^ITEM="IV-622  readargument contains indirections"
 S ^NEXT="V4READ4^V4READ,V4KEY^VV4" D ^V4PRESET K  K ^VV
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 S ^VV="^VV(1,2)",^VV(1,2,3)="^VV(1,2,3,4)"
 S N="N(1)",N(1)="3",M=2,^VV(2)="@^VV(3)",^VV(3)="^VV(4)"
 S ^VV(1,2,3,4)="!,""   R @@@^VV@(@N) ; Type 3 characters 'xyz' and a <CR> : "",@^VV(M)"
 R !,@@@^VV@(@N)
 S ^VCOMP=^VV(4),^VCORR="xyz"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G J
 D ^VEXAMINE K ^VV
 ;
END W !!,"End of 95 --- V4READ3",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
