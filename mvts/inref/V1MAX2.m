V1MAX2 ;IW-YS-TS,V1MAX,MVTS V9.10;15/6/96;MAXIMUM RANGE -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"179---V1MAX2: Maximum range -2-",!
 ;
622 W !,"I-622  Numeric range ( 10 power -25 to 10 power 25 )"
 S ^ABSN="12038",^ITEM="I-622  Numeric range ( 10 power -25 to 10 power 25 )",^NEXT="623^V1MAX2,V1MAX3^V1MAX,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-622 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
623 W !,"I-623  Significant digit up to 9 digits"
 S ^ABSN="12039",^ITEM="I-623.1  Local data",^NEXT="6232^V1MAX2,V1MAX3^V1MAX,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-623.1 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
6232 S ^ABSN="12040",^ITEM="I-623.2  Global data",^NEXT="V1MAX3^V1MAX,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-623.2 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 179---V1MAX2",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
