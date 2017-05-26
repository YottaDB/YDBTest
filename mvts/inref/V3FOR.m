V3FOR ;IW-KO-YS-TS,VV3,MVTS V9.10;15/6/96;PART-90 SUB-DRIVER
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"2.6.5  FOR Command"
 W !,"Argumentless FOR Command except QUIT with argument, and "
 W !,"extrisic function call",!
 ;
V3FOR1 W !!,"21---V3FOR1" D ^V3FOR1
V3FOR2 W !!,"22---V3FOR2" D ^V3FOR2
 ;
END K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
