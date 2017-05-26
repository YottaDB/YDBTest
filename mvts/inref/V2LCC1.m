V2LCC1 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LOWER CASE COMMAND WORDS AND $data -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"2---V2LCC1: Lower case command words and $data -1-",!
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (2---V2LCC1) contains 2 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
9 W !,"II-9  for"
 S ^ABSN="20009",^ITEM="II-9  for",^NEXT="10^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" for I=1:1:3 S ^VCOMP=^VCOMP_I
 fOR I(2)=-5:-1:-7 S ^VCOMP=^VCOMP_I(2) ;COMMENT
 S ^VCORR="123-5-6-7" D ^VEXAMINE
 ;
10 W !,"II-10  f"
 S ^ABSN="20010",^ITEM="II-10  f",^NEXT="11^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" f I=3:1:5.5 SET ^VCOMP=^VCOMP_I
 S ^VCORR="345" D ^VEXAMINE
 ;
11 W !,"II-11  write   (by OPERATOR)"
 S ^ABSN="20011",^ITEM="II-11  write  (by OPERATOR)",^NEXT="12^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 W !,"       Following two lines should be identical:"
 W !,"   write  "
 write !,"   write  "
 D MANPF2^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 11
 ;
12 W !,"II-12  w   (by OPERATOR)"
 S ^ABSN="20012",^ITEM="II-12  w   (by OPERATOR)",^NEXT="13^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 W !,"       Following two lines should be identical:"
 W !,"   w  "
 w !,"   w  "
 D MANPF2^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 12
 ;
13 W !,"II-13  do"
 S ^ABSN="20013",^ITEM="II-13  do",^NEXT="14^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" do C S ^VCORR="do" D ^VEXAMINE ;(test corrected in V7.2;24/2/88)
 ;
14 W !,"II-14  d"
 S ^ABSN="20014",^ITEM="II-14  d",^NEXT="15^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" d C1 S ^VCORR="d" D ^VEXAMINE ;(test corrected in V7.2;24/2/88)
 ;
15 W !,"II-15  hang"
 S ^ABSN="20015",^ITEM="II-15  hang",^NEXT="16^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP=1 ;(test changed in V7.5;20/8/90)
 hang 1 S ^VCOMP=^VCOMP_2
 S ^VCOMP=^VCOMP_3
 S ^VCORR="123" D ^VEXAMINE
 ;
16 W !,"II-16  h"
 S ^ABSN="20016",^ITEM="II-16  h",^NEXT="17^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP=11 ;(test changed in V7.5;20/8/90)
 h .1 S ^VCOMP=^VCOMP_22
 S ^VCOMP=^VCOMP_33
 S ^VCORR="112233" D ^VEXAMINE
 ;
17 W !,"II-17  quit"
 S ^ABSN="20017",^ITEM="II-17  quit",^NEXT="18^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" DO EX17 S ^VCORR="quit" D ^VEXAMINE ;(test corrected in V7.2;24/2/88)
 ;
18 W !,"II-18  q"
 S ^ABSN="20018",^ITEM="II-18  q",^NEXT="19^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" DO EX18 S ^VCORR="q" D ^VEXAMINE ;(test corrected in V7.2;24/2/88)
 ;
19 W !,"II-19  goto"
 S ^ABSN="20019",^ITEM="II-19  goto",^NEXT="20^V2LCC1,V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" goto D S ^VCOMP=^VCOMP_"ERROR goto"
 S ^VCOMP=^VCOMP_"ERROR goto next line"
G19 S ^VCORR="goto" D ^VEXAMINE
 ;
20 W !,"II-20  g"
 S ^ABSN="20020",^ITEM="II-20  g",^NEXT="V2LCC2^VV2" D ^V2PRESET
 S ^VCOMP="" g D1 S ^VCOMP=^VCOMP_"ERROR g"
 S ^VCOMP=^VCOMP_"ERROR g next line"
G20 S ^VCORR="g" D ^VEXAMINE
 ;
END w !!,"End of 2---V2LCC1",!
 k  q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
C S ^VCOMP=^VCOMP_"do" QUIT  S ^VCOMP=^VCOMP_"ERROR do"
 S ^VCOMP=^VCOMP_"ERROR do next line" QUIT
C1 S ^VCOMP=^VCOMP_"d" Q  S ^VCOMP=^VCOMP_"ERROR d"
 S ^VCOMP=^VCOMP_"ERROR d next line" QUIT
D S ^VCOMP=^VCOMP_"goto" G G19 S ^VCOMP=^VCOMP_"ERROR D goto "
 S ^VCOMP=^VCOMP_"ERROR D goto next line" GOTO G19
D1 S ^VCOMP=^VCOMP_"g" G G20 S ^VCOMP=^VCOMP_"ERROR D1 goto "
 S ^VCOMP=^VCOMP_"ERROR D1 goto next line"
 GOTO G20
EX17 S ^VCOMP=^VCOMP_"quit" quit  S ^VCOMP=^VCOMP_"ERROR EX17 quit"
 S ^VCOMP=^VCOMP_"ERROR EX17 next line" QUIT
EX18 S ^VCOMP=^VCOMP_"q" q  S ^VCOMP=^VCOMP_"ERROR EX18 q"
 S ^VCOMP=^VCOMP_"ERROR EX18 next line" QUIT
