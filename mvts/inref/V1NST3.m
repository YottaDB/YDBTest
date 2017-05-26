V1NST3 ;IW-KO-YS-TS,VV1,MVTS V9.10;15/6/96;NESTING LEVEL -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"169---V1NST3: Nesting ( FOR, XECUTE, DO, @, <FUNCTION> ) -3-"
 W !,"As this routine itself is counted as one level of nesting,"
 W !,"additional 14 levels of nesting are required." W:$Y>55 #
 W !,"admitted nesting levels are indicated by the number in each test.",!
 ;
660 W !,"I-660  Effect of GOTO on nesting"
6601 S ^ABSN="11963",^ITEM="I-660.1  Local GOTO",^NEXT="6602^V1NST3,V1JST^VV1" D ^V1PRESET
 W !,"       (This test I-660.1 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
6602 S ^ABSN="11964",^ITEM="I-660.2  External GOTO",^NEXT="661^V1NST3,V1JST^VV1" D ^V1PRESET
 W !,"       (This test I-660.2 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
661 W !,"I-661  Effect of QUIT on nesting"
 S ^ABSN="11965",^ITEM="I-661  Effect of QUIT on nesting",^NEXT="V1JST^VV1" D ^V1PRESET
 W !,"       (This test I-661 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 169---V1NST3",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
