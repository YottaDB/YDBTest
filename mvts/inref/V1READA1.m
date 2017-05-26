V1READA1 ;IW-KO-TS,V1READA,MVTS V9.10;15/6/96;READ COMMAND -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>50 #
 W !!,"182---V1READA1: READ command -1-",!
749 W !,"READ lvn :"
 S ^ABSN="12052",^ITEM="I-749  readargument is string literal",^NEXT="750^V1READA1,V1READA2^V1READA,V1READB^VV1" D ^V1PRESET
 W !,"I-749  readargument is string literal"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 READ !!,"TEST I-749: Type 5 charcters 'MUMPS' and a <CR> : ",!,"   ",M
 S ^VCOMP=M
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR="MUMPS"
 D AGAIN^VEXAMINE I RES="YES" G 749
 D ^VEXAMINE
 ;
750 W !!,"I-750  readargument is format control characters"
 S ^ABSN="12053",^ITEM="I-750  readargument is format control characters",^NEXT="751^V1READA1,V1READA2^V1READA,V1READB^VV1" D ^V1PRESET
 S ^VCOMP=""
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"TEST I-750: Type 6 characters  :;<>?@  separating by a <CR> : "
 R !?10,%1,!?10,%2,!?10,%3,!?10,%4,!?10,%5,!?10,%6
 S ^VCOMP=%1_%2_%3_%4_%5_%6
 I %1=":",%2=";",%3="<",%4=">",%5="?",%6="@" S ^VCOMP=^VCOMP_" ... OK "
 E  S ^VCOMP=^VCOMP_" ... NOT OK "
 S ^VCOMP=^VCOMP_(%1=":")_(%2=";")_(%3="<")_(%4=">")_(%5="?")_(%6="@")
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCORR=":;<>?@ ... OK 111111"
 D AGAIN^VEXAMINE I RES="YES" G 750
 D ^VEXAMINE
 ;
751 W !!,"I-751  Read an empty string"
 S ^ABSN="12054",^ITEM="I-751  Read an empty string",^NEXT="752^V1READA1,V1READA2^V1READA,V1READB^VV1" D ^V1PRESET
 S VCOMP="ERROR"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 R !!,"TEST I-751: Type only a <CR> : ",VCOMP
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=VCOMP,^VCORR=""
 D AGAIN^VEXAMINE I RES="YES" G 751
 D ^VEXAMINE
 ;
752 W !!,"I-752  Read 255 characters length data"
 S ^ABSN="12055",^ITEM="I-752  Read 255 characters length data",^NEXT="V1READA2^V1READA,V1READB^VV1" D ^V1PRESET
 S VCOMP="A"
 S V="" F I=1:1:255 S V=V_"A"
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !!,"TEST I-752: Type 255 charcters  ",!,V R "  and a <CR> : ",!,VCOMP
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 S ^VCOMP=VCOMP,^VCORR=V
 D AGAIN^VEXAMINE I RES="YES" G 752
 D ^VEXAMINE
 ;
END W !!,"End of 182---V1READA1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
