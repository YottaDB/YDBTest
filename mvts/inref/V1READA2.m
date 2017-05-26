V1READA2 ;IW-KO-TS,V1READA,MVTS V9.10;15/6/96;READ COMMAND -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>50 #
 W !!,"183---V1READA2: READ command -2-",!
 ;
753 W !!,"I-753  Read upper-case alphabetics"
 S ^ABSN="12056",^ITEM="I-753  Read upper-case alphabetics",^NEXT="754^V1READA2,V1READA3^V1READA,V1READB^VV1" D ^V1PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 READ !!,"TEST I-753: Type 26 characters 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' and a <CR> : "
 W !,"                                " R % S VCOMP=%
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=VCOMP,^VCORR="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 D AGAIN^VEXAMINE I RES="YES" G 753
 D ^VEXAMINE
 ;
754 W !!,"I-754  Read lower-case alphabetics"
 S ^ABSN="12057",^ITEM="I-754  Read lower-case alphabetics",^NEXT="755^V1READA2,V1READA3^V1READA,V1READB^VV1" D ^V1PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"TEST I-754: Type 26 characters 'abcdefghijklmnopqrstuvwxyz' and a <CR> : ",!,"                                ",%2345678 S ^VCOMP=%2345678
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="abcdefghijklmnopqrstuvwxyz"
 D AGAIN^VEXAMINE I RES="YES" G 754
 D ^VEXAMINE
 ;
755 W !!,"I-755  Read punctuations"
 S ^ABSN="12058",^ITEM="I-755  Read punctuations",^NEXT="756^V1READA2,V1READA3^V1READA,V1READB^VV1" D ^V1PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"I-755: Type 33 characters  ! ""#$%&'()*+,-./:;<=>?@[\]^_`{|}~  and a <CR> (notice the space) : ",!,"                           ",%1A2B3C4 S ^VCOMP=%1A2B3C4
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="! ""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
 D AGAIN^VEXAMINE I RES="YES" G 755
 D ^VEXAMINE
 ;
756 W !!,"I-756  Read numerics"
 S ^ABSN="12059",^ITEM="I-756  Read numerics",^NEXT="V1READA3^V1READA,V1READB^VV1" D ^V1PRESET
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"I-756: Type 10 characters '1234567890' and a <CR> : ",!,"                           ",ABCDEFGH S ^VCOMP=ABCDEFGH
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="1234567890"
 D AGAIN^VEXAMINE I RES="YES" G 756
 D ^VEXAMINE
 ;
END W !!,"End of 183---V1READA2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
