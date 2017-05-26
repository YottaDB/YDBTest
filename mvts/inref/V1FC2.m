V1FC2 ;IW-YS-TS,V1FC,MVTS V9.10;15/6/96;FORMAT CONTROL CHARACTERS -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 I $Y>50 W #
 W !!,"19---V1FC2: Format control characters -2-",!
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (19---V1FC2) contains 3 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " s Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
254 I $Y>50 W #
 W !!!,"Tab operation  ?intexpr"
 I $Y>50 W #
 W !!,"I-254  intexpr is positive integer (by OPERATOR)"
 S ^ABSN="10184",^ITEM="I-254  intexpr is positive integer (by OPERATOR)",^NEXT="255^V1FC2,V1FC3^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical: (five times)"
 I $Y>50 W #
 W !,"          1         2         3         4         5         6"
 W !,?10,1,?20,2,?30,3,?40,4,?50,5,?60,6
 W !,"12345     12345     12345     12345     12345     12345     12345"
 W !,12345,?10,12345,?20,12345,?30,12345,?40,12345,?50,12345
 W ?60,12345
 I $Y>50 W #
 W !,"          A         B         C         D         E         F"
 W !?10,"A",?20,"B",?30,"C",?40,"D",?50,"E",?60,"F"
 W !,"ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH"
 W !,"ABCDEFGH",?10,"ABCDEFGH",?20,"ABCDEFGH",?30,"ABCDEFGH",?40
 W "ABCDEFGH",?50,"ABCDEFGH",?60,"ABCDEFGH"
 W !,"1.23      -1.23     123       123       0         0         10"
 W !,1.23,?10,-1.23,?20,000000123,?30,000000123.00000,?40,-.000000,?50,00000E000,?60,1E1
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 254
 ;
255 I $Y>50 W #
 W !!!,"I-255  intexpr is zero (by OPERATOR)"
 S ^ABSN="10185",^ITEM="I-255  intexpr is zero (by OPERATOR)",^NEXT="256^V1FC2,V1FC3^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following three lines should be identical:"
 W !,"12345     12345     12345     12345     12345     12345     12345"
 W !?00,12345.0,?10,012345,?20,0012345,?30,12345.000,?40,12345,?50,12345,?60,12345
 W !?"ABC",12345,?0,?10,12345,?20,12345,?30.2000,12345,?40.0,12345.00000,?50,12345,?60,123_45
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 255
 ;
256 I $Y>50 W #
 W !!!,"I-256  intexpr less than zero (by OPERATOR)"
 S ^ABSN="10186",^ITEM="I-256  intexpr less than zero (by OPERATOR)",^NEXT="V1FC3^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"ABC       ABC       ABC       ABC       ABC       ABC       ABC"
 W !,"ABC       AB",?-10,"C       ABC       A",?-20,"BC",?30,"       A",?-40,"BC",?50,"ABC",?60,"ABC"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 256
 ;
END W !!,"End of 19---V1FC2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
