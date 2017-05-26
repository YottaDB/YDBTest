V1FC3 ;IW-YS-TS,V1FC,MVTS V9.10;15/6/96;FORMAT CONTROL CHARACTERS -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 I $Y>50 W #
 W !!,"20---V1FC3: Format control characters -3-",!
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (20---V1FC3) contains 6 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y" 
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
257 I $Y>50 W #
 W !!!,"I-257  intexpr is non-integer numeric literal (by OPERATOR)"
 S ^ABSN="10187",^ITEM="I-257  intexpr is non-integer numeric literal (by OPERATOR)",^NEXT="258^V1FC3,V1UO^VV1" D ^V1PRESET
 W !,"       Following three lines should be identical:"
 W !,"          1         2         3         4         5         6"
 W !,?10.0,1,?20.1,2,?30.4,3,?40.550,4,?50.9,5,?60.99999,6
 W !,"  ",?10.00,"1",?2.0E1,1+1,?305E-1,"3",?409E-01
 W "4",?000050.19,"5",?0060.990000,"6"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 257
 ;
258 I $Y>50 W #
 W !!!,"I-258  intexpr contains binary operator (by OPERATOR)"
 S ^ABSN="10188",^ITEM="I-258  intexpr contains binary operator (by OPERATOR)",^NEXT="259^V1FC3,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"-12345    -12345    -12345    -12345    -12345    -12345    -12345"
 W !?-3,-12345,?10.9,-12345,?1='0+19,-12345,?"30A",-12345,?4E1,-12345
 W ?1=1>0*50,-12345,?-40+"100",-12345
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 258
 ;
259 I $Y>50 W #
 W !!!,"I-259  intexpr contains unary operator (by OPERATOR)"
 S ^ABSN="10189",^ITEM="I-259  intexpr contains unary operator (by OPERATOR)",^NEXT="260^V1FC3,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"          A         B         C         D         E         F"
 W !?+10,"A",?++"20","B",?+"30ABC","C",?-"-40QWE","D",?"5E1AKLS"
 W "E",?--"6000E-2 1234","F"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 259
 ;
260 I $Y>50 W #
 W !!!,"I-260  intexpr is a function (by OPERATOR)"
 S ^ABSN="10190",^ITEM="I-260  intexpr is a function (by OPERATOR)",^NEXT="261^V1FC3,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH"
 W !,"ABCDEFGH",?$E(20301040,5,6),"ABCDEFGH",?2_0,"ABCDEFGH"
 W ?$P("10^20^30^40","^",3),"ABCDEFGH",?$F("ABCDEF","C")_0
 W "ABCDEFGH",?50,"ABCDEFGH",?$A("<"),"ABCDEFGH"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 260
 ;
261 I $Y>50 W #
 W !!!,"I-261  intexpr is variable name (by OPERATOR)"
 S ^ABSN="10191",^ITEM="I-261  intexpr is variable name (by OPERATOR)",^NEXT="262^V1FC3,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB  BBBBBBBB"
 S A="#",B="BBBBBBBB",C=10,D=20.5,E="30",A(4)=40
 W !,?A,B,?C,B,?D,B,?E,B,?A(4),B,?A(4)+10,B,?A+A(4)+D,B
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 261
 ;
262 I $Y>50 W #
 W !!!,"I-262  intexpr is greater than $X (by OPERATOR)"
 S ^ABSN="10192",^ITEM="I-262  intexpr is greater than $X (by OPERATOR)",^NEXT="V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"ABC       ABC       ABC       ABC       ABC       ABC       ABC"
 W !,"ABC       AB",?10,"C       ABC       A",?20,"BC",?30,"       A",?40,"BC",?50,"ABC",?60,"ABC"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 262
 ;
END W !!!,"End of 20---V1FC3",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
