V1LL0 ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;LABELLESS FIRST LINE
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
609 W !!,"3---V1LL0: The first line is labelless",!
 W:$Y>55 #
 W !,"I-609  The first line is labelless"
 S ^ABSN="10010",^ITEM="I-609  The first line is labelless",^NEXT="V1LL1^VV1" D ^V1PRESET
 S VCOMP=""
 D ^V1LL0FL
 S ^VCOMP=VCOMP,^VCORR="LABELLESS OK" D ^VEXAMINE
 ;
END W !!,"End of 3---V1LL0",!
 K  Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
