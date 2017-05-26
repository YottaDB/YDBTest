V4KEY ;IW-KO-YS-TS,VV4,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"97---V4KEY:  Special variable $KEY"
A ;
1 W !!,"IV-627  terminated by CR"
 S ^ABSN="40627",^ITEM="IV-627  terminated by CR"
 S ^NEXT="2^V4KEY,V4SYSTEM^VV4" D ^V4PRESET K
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 READ !,"   READ VV : Type 3 characters 'ABC' and a <CR> : ",VV
 S ^VCOMP=VV_" "_($KEY=$C(13))_" "_($key=$C(13))
 S ^VCORR="ABC 1 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G A
 D ^VEXAMINE
 ;
B ;
2 W !!,"IV-628  terminated by timeout"
 S ^ABSN="40628",^ITEM="IV-628  terminated by timeout"
 S ^NEXT="3^V4KEY,V4SYSTEM^VV4" D ^V4PRESET K
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !,"   R VV:10 ; Type 2 chars 'AB' within 10 seconds ",!,"             and NEVER touch <CR> : ",VV:10
 S ^VCOMP=VV_" "_$TEST_" "_($K="")_" "_($k="")
 S ^VCORR="AB 0 1 1"
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 D AGAIN^VEXAMINE I RES="YES" G B
 D ^VEXAMINE
 ;
C ;
3 W !!,"IV-629  no READ command"
 S ^ABSN="40629",^ITEM="IV-629  no READ command"
 S ^NEXT="V4SYSTEM^VV4" D ^V4PRESET K  K ^VV
 JOB KEY::60 S WAIT=$T
 IF $T F I=1:1:60 Q:$D(^VV)#10=1  H 1
 H 1
 I $D(^VV)#10=0 S ^VV="ERROR"
 S ^VCOMP=^VV
 S ^VCORR="" D ^VEXAMINE
 ;
END W !!,"End of 97 --- V4KEY",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
KEY S ^VV=$KEY Q
 H
 ;
