V1PRSET ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;PRELIMINARY TEST OF SET AND KILL COMMANDS
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"9---V1PRSET: Preliminary tests of SET and KILL commands",! W:$Y>55 #
 ;
 I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 W !,"This routine (9---V1PRSET) contains 4 tests to be checked by OPERATOR."
REP W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 IF Y="Y" GOTO REP1
 IF Y="y" GOTO REP1
 GOTO REP
REP1 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
734 W !,"I-734  SET local variables without subscript (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10058",^ITEM="I-734  SET local variables without subscript (by OPERATOR)",^NEXT="735^V1PRSET,V1PRIE^VV1" D ^V1PRESET
 W !,"1A"
 S A=1 W !,A
 S X="A" W X
 D MANPF1^VEXAMINE I $D(RES)=1 I RES="AGAIN" G 734
 ;
735 W !!,"I-735  Setargument list (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10059",^ITEM="I-735  Setargument list (by OPERATOR)",^NEXT="736^V1PRSET,V1PRIE^VV1" D ^V1PRESET
 W !,"234BCD",!
 S A=2,B=3,C=4 W A,B,C
 S Y="B",Z="C",V="D" W Y,Z,V
 D MANPF1^VEXAMINE W:$Y>55 # I $D(RES)=1 I RES="AGAIN" G 735
 ;
736 W !!,"I-736  Reassignment (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10060",^ITEM="I-736  Reassignment (by OPERATOR)",^NEXT="737^V1PRSET,V1PRIE^VV1" D ^V1PRESET
 S A=1,A=2,B=3,C=4,X="A"
 S Y="B",Z="C",V="D"
 S W=A,A=B,B=C,C=X,X=Y,Y=Z,Z=V,V=W
 W !,"34ABCD22"
 W !,A,B,C,X,Y,Z,V,W
 D MANPF1^VEXAMINE W:$Y>55 # I $D(RES)=1 I RES="AGAIN" G 736
 ;
737 W !!,"I-737  KILL local variables all (by OPERATOR)"
 W !,"       Following two lines should be identical:"
 S ^ABSN="10061",^ITEM="I-737  KILL local variables all (by OPERATOR)",^NEXT="V1PRIE^VV1" D ^V1PRESET
 W !,"KILL local variables all is accepted"
KILL KILL  W !,"KILL local variables all is accepted"
 D MANPF1^VEXAMINE W:$Y>55 # I $D(RES)=1 I RES="AGAIN" G 737
 ;
END W !!,"End of 9---V1PRSET",! W:$Y>55 #
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
