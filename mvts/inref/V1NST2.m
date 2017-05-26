V1NST2 ;IW-KO-YS-TS,VV1,MVTS V9.10;15/6/96;NESTING LEVEL -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"168---V1NST2: Nesting ( FOR, XECUTE, DO, @, <FUNCTION> ) -2-"
 W !,"As this routine itself is counted as one level of nesting,"
 W !,"additional 14 levels of nesting are required." W:$Y>55 #
 W !,"admitted nesting levels are indicated by the number in each test.",!
 ;
657 W !,"I-657  1 level of DO, and 14 levels of argument level indirection"
 S ^ABSN="11960",^ITEM="I-657  1 level of DO, and 14 levels of argument level indirection",^NEXT="658^V1NST2,V1NST3^VV1" D ^V1PRESET
 W !,"       (This test I-657 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
658 W !,"I-658  1 level of DO, and 14 levels of name level indirection"
 S ^ABSN="11961",^ITEM="I-658  1 level of DO, and 14 levels of name level indirection",^NEXT="659^V1NST2,V1NST3^VV1" D ^V1PRESET
 W !,"       (This test I-658 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
659 W !,"I-659  Up to 6 nesting levels of functions"
FNC S ^ABSN="11962",^ITEM="I-659  Up to 6 nesting levels of functions",^NEXT="V1NST3^VV1" D ^V1PRESET
 W !,"       (This test I-659 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 168---V1NST2",!
 K  K ^V1ID Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
