V1NST1 ;IW-KO-YS-TS,VV1,MVTS V9.10;15/6/96;NESTING LEVEL -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"167---V1NST1: Nesting ( FOR, XECUTE, DO, @, <FUNCTION> ) -1-"
 W !,"As this routine itself is counted as one level of nesting,"
 W !,"additional 14 levels of nesting are required." W:$Y>55 #
 W !,"admitted nesting levels are indicated by the number in each test.",!
653 W !,"I-653  1 level of DO, and 14 levels of FOR"
6531 S ^ABSN="11954",^ITEM="I-653.1  Termination by GOTO",^NEXT="6532^V1NST1,V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-653.1 was withdrawn in 1983 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
6532 S ^ABSN="11955",^ITEM="I-653.2  Termination by QUIT",^NEXT="654^V1NST1,V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-653.2 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
654 W !,"I-654  1 level of DO, and 14 levels of XECUTE"
 S ^ABSN="11956",^ITEM="I-654  1 level of DO, and 14 levels of XECUTE",^NEXT="655^V1NST1,V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-654 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
655 W !,"I-655  15 levels of DO"
6551 S ^ABSN="11957",^ITEM="I-655.1  Local DO",^NEXT="6552^V1NST1,V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-655.1 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
6552 S ^ABSN="11958",^ITEM="I-655.2  External DO",^NEXT="656^V1NST1,V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-655.2 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
656 W !,"I-656  15 levels of combined DO, FOR, XECUTE"
 S ^ABSN="11959",^ITEM="I-656  15 levels of combined DO, FOR, XECUTE",^NEXT="V1NST2^VV1" D ^V1PRESET
 W !,"       (This test I-656 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 167---V1NST1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
