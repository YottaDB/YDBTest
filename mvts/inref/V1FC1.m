V1FC1 ;IW-YS-TS,V1FC,MVTS V9.10;15/6/96;FORMAT CONTROL CHARACTERS -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 I $Y>50 W #
 W !!,"18---V1FC1: Format control characters -1-",!
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (18---V1FC1) contains 6 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
248 I $Y>50 W #
 W !!,"I-248  Parameters occur in a single instance of format (by OPERATOR)"
 S ^ABSN="10178",^ITEM="I-248  Parameters occur in a single instance of format (by OPERATOR)",^NEXT="249^V1FC1,V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"       12345"
 W !
 W ?7
 W 12345
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 248
 ;
249 I $Y>50 W #
 W !!,"I-249  ""New line"" operation by ! (by OPERATOR)"
 S ^ABSN="10179",^ITEM="I-249  ""New line"" operation by ! (by OPERATOR)",^NEXT="250^V1FC1,V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"""New line"" operation by !",!,"""New line"" operation by !"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 249
 ;
250 W !!,"I-250  ""Top of page"" operation by # (by OPERATOR)"
 S ^ABSN="10180",^ITEM="I-250  ""Top of page"" operation by # (by OPERATOR)",^NEXT="251^V1FC1,V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W #,"Top of page operation by #"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 250
 ;
251 I $Y>50 W #
 W !!,"I-251  Effect of comma in WRITE command (by OPERATOR)"
 S ^ABSN="10181",^ITEM="I-251  Effect of comma in WRITE command (by OPERATOR)",^NEXT="252^V1FC1,V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"01 0 000 A",$C(34),"B ABC"
 W !,0,1," ",000," ",0,0,0," ","A""B"," ","A","B","C"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 251
 ;
252 I $Y>50 W #
 W !!,"I-252  Effect of comma between ""new line operator"" (!) (by OPERATOR)"
 S ^ABSN="10182",^ITEM="I-252  Effect of comma between ""new line operator"" (!) (by OPERATOR)",^NEXT="253^V1FC1,V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       CORRECT OUTPUT: 5 ROWS OF ASTERISKS; 1ST AND 2ND ROWS SINGLE"
 W !,"       PACED, 2ND AND 3RD SKIP ONE LINE, 3RD AND 4TH SKIP 2 LINES,"
 W !,"       4TH AND 5TH SKIP 3 LINES",!!
 I $Y>50 W #
 W "*****",!,"*****",!!,"*****",!,!,!,"*****",!!!!,"*****"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 252
 ;
253 I $Y>50 W #
 W !!,"I-253  Effect of comment delimiter on format (by OPERATOR)"
 S ^ABSN="10183",^ITEM="I-253  Effect of comment delimiter on format (by OPERATOR)",^NEXT="V1FC2^V1FC,V1UO^VV1" D ^V1PRESET
 W !,"       Following two lines should be identical:"
 W !,"COMMENT DELIMITERS ;OUTPUT IS ON ONE LINE"
 W !,"COMMENT DELIMITERS ;" ; THIS SHOULD BE IGNORED
 ; IGNORE THIS, TOO
 W "OUTPUT IS ON ONE LINE"
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 253
 ;
END W !!!,"End of 18---V1FC1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
