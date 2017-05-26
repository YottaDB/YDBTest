V1MAX3 ;IW-YS-TS,V1MAX,MVTS V9.10;15/6/96;MAXIMUM RANGE -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"180---V1MAX3: Maximum range -3-",!
624 W !,"I-624  9 digits subscript of local variable"
 S ^ABSN="12041",^ITEM="I-624  9 digits subscript of local variable",^NEXT="625^V1MAX3,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-624 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
625 W !,"I-625  9 digits subscript of global variable"
 S ^ABSN="12042",^ITEM="I-625  9 digits subscript of global variable",^NEXT="626^V1MAX3,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-625 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
626 W !,"I-626  15 levels subscript of local variable"
 S ^ABSN="12043",^ITEM="I-626  15 levels subscript of local variable",^NEXT="627^V1MAX3,V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-626 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
627 W !,"I-627  15 levels subscript of global variable"
 S ^ABSN="12044",^ITEM="I-627  15 levels subscript of global variable",^NEXT="V1BR^VV1" D ^V1PRESET
 W !,"       (This test I-627 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 180---V1MAX3",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
