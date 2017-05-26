V1NX1 ;IW-YS-TS,V1NX,MVTS V9.10;15/6/96;$NEXT FUNCTION -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"119---V1NX1: $NEXT function -1-",!
 ;
669 W !,"I-669  glvn is not defined"
 S ^ABSN="11551",^ITEM="I-669  glvn is not defined",^NEXT="670^V1NX1,V1NX2^V1NX,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-669 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
670 W !,"I-670  glvn has no neighboring node"
 S ^ABSN="11552",^ITEM="I-670  glvn has no neighboring node",^NEXT="671^V1NX1,V1NX2^V1NX,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-670 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
671 W !,"I-671  The last subscript of glvn is -1"
 S ^ABSN="11553",^ITEM="I-671  The last subscript of glvn is -1",^NEXT="672^V1NX1,V1NX2^V1NX,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-671 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
672 W !,"I-672  glvn as naked reference"
 S ^ABSN="11554",^ITEM="I-672  glvn as naked reference",^NEXT="673^V1NX1,V1NX2^V1NX,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-672 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
673 W !,"I-673  Expected returned value is zero"
 S ^ABSN="11555",^ITEM="I-673  Expected returned value is zero",^NEXT="V1NX2^V1NX,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-673 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 119---V1NX1",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
