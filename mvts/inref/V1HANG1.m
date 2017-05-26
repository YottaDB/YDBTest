V1HANG1 ;IW-KO-TS,VV1,MVTS V9.10;15/6/96;HANG COMMAND  -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>45 #
 W !!,"189---V1HANG1: HANG command  -1-",!
 ;
 ;I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 ;W !,"This routine (189---V1HANG1) contains 8 tests to be checked by OPERATOR."
REP ;W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 ;IF Y="Y" GOTO REP1
 ;IF Y="y" GOTO REP1
 ;GOTO REP
REP1 ;I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
 ;D MSG
 ;
401 W !!,"I-401  HANG duration by $H (by OPERATOR)"
 S ^ABSN="12082",^ITEM="I-401  HANG duration by $H (by OPERATOR)",^NEXT="402^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-401 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
402 W !!,"I-402  List of hangargument (by OPERATOR)"
 S ^ABSN="12083",^ITEM="I-402  List of hangargument (by OPERATOR)",^NEXT="403^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-402 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
403 W !!,"I-403  HANG in FOR scope (by OPERATOR)"
 S ^ABSN="12084",^ITEM="I-403  HANG in FOR scope (by OPERATOR)",^NEXT="404^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-403 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
404 W !!,"I-404  HANG with postconditional (by OPERATOR)"
 S ^ABSN="12085",^ITEM="I-404  HANG with postconditional (by OPERATOR)",^NEXT="405^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-404 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
405 W !!,"I-405  Argument level indirection (by OPERATOR)"
 S ^ABSN="12086",^ITEM="I-405  Argument level indirection (by OPERATOR)",^NEXT="406^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-405 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
406 W !!,"I-406  Name level indirection (by OPERATOR)"
 S ^ABSN="12087",^ITEM="I-406  Name level indirection (by OPERATOR)",^NEXT="407^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-406 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
407 W !!,"HANG numexpr"
 W !!,"I-407  numexpr is integer (by OPERATOR)"
 S ^ABSN="12088",^ITEM="I-407  numexpr is integer (by OPERATOR)",^NEXT="408^V1HANG1,V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-407 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
408 W !!,"I-408  numexpr=0 (by OPERATOR)"
 S ^ABSN="12089",^ITEM="I-408  numexpr=0 (by OPERATOR)",^NEXT="V1HANG2^V1HANG,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-408 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 189---V1HANG1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
MSG I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE") ;(test corrected in V7.3;20/6/88)
 W !!,"Each test consists of three steps."
 W !," 1st: HANG commands to be executed appear."
 W !," 2nd: HANG commands are executed with the start carret '>'"
 W !,"      and end with the stop carret '<'."
 W !," 3rd: Expected & measured hang durations appear."
 W !!,"HANG time is measured with $HOROLOG in this routine."
 W !," With a view to test $HOROLOG,"
 W !," it is essential to use stop-watch simultaneously.",!
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 Q
 ;
START I $Y>55 W #
 W !,"       ",CMD,?35,">" S H=$H Q
STOP S H=$$^difftime($H,H) W "<  EXPECTED:",TM,?55,"MEASURED:",H Q
