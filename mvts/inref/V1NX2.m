V1NX2 ;IW-YS-TS,V1NX,MVTS V9.10;15/6/96;$NEXT FUNCTION -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"120---V1NX2: $NEXT function -2-",!
 ;
674 W !,"I-674  glvn is lvn"
 S ^ABSN="11556",^ITEM="I-674  glvn is lvn",^NEXT="675^V1NX2,V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-674 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
675 W !,"I-675  glvn is gvn"
 S ^ABSN="11557",^ITEM="I-675  glvn is gvn",^NEXT="V1SET^VV1" D ^V1PRESET
 W !,"       (This test I-675 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-77",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 120---V1NX2",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
