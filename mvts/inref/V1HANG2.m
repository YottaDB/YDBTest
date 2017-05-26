V1HANG2 ;IW-KO-TS,VV1,MVTS V9.10;15/6/96;HANG COMMAND -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W:$Y>45 #
 W !!,"190---V1HANG2: HANG command  -2-",!
 ;
 ;I $D(^VENVIRON("INPUT USE"))=1 U ^VENVIRON("INPUT USE")
 ;W !,"This routine (190---V1HANG2) contains 8 tests to be checked by OPERATOR."
REP ;W !!,"When you are ready, press ""Y/y"" and a <CR> : " S Y="Y"
 ;IF Y="Y" GOTO REP1
 ;IF Y="y" GOTO REP1
 ;GOTO REP
REP1 ;I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 ;
 ;D MSG^V1HANG1
 ;
409 W !!,"I-409  numexpr<0 (by OPERATOR)"
 ;W !!,"Don't touch any key till P/F question appears in a moment." ;(message added in V7.5;20/8/90)
 ;W !,"If not, the system must have halted!,",!
 S ^ABSN="12090",^ITEM="I-409  numexpr<0 (by OPERATOR)",^NEXT="410^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-409 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
410 W !!,"I-410  numexpr is non-integer positive numeric literal (by OPERATOR)"
 S ^ABSN="12091",^ITEM="I-410  numexpr is non-integer positive numeric literal (by OPERATOR)",^NEXT="411^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-410 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
411 W !!,"I-411  numexpr is greater than zero and less than one (by OPERATOR)"
 S ^ABSN="12092",^ITEM="I-411  numexpr is greater than zero and less than one (by OPERATOR)",^NEXT="412^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-411 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
412 W !!,"I-412  numexpr is string literal (by OPERATOR)"
 S ^ABSN="12093",^ITEM="I-412  numexpr is string literal (by OPERATOR)",^NEXT="413^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-412 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
413 W !!,"I-413  numexpr is an empty string (by OPERATOR)"
 S ^ABSN="12094",^ITEM="I-413  numexpr is an empty string (by OPERATOR)",^NEXT="414^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-413 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
414 W !!,"I-414  numexpr is lvn (by OPERATOR)"
 S ^ABSN="12095",^ITEM="I-414  numexpr is lvn (by OPERATOR)",^NEXT="415^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-414 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
415 W !!,"I-415  numexpr contains unary operator (by OPERATOR)"
 S ^ABSN="12096",^ITEM="I-415  numexpr contains unary operator (by OPERATOR)",^NEXT="416^V1HANG2,V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-415 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
416 W !!,"I-416  numexpr contains binary operator (by OPERATOR)"
 S ^ABSN="12097",^ITEM="I-416  numexpr contains binary operator (by OPERATOR)",^NEXT="V1PO^VV1" D ^V1PRESET
 W !,"       (This test I-416 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 190---V1HANG2",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
START I $Y>55 W #
 W !,"       ",CMD,?35,">" S H=$H Q
STOP S H=$$^difftime($H,H) W "<  EXPECTED:",TM,?55,"MEASURED:",H Q
