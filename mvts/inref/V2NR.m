V2NR ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;NAKED REFERENCE
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"17---V2NR: Naked references",!
136 W !,"II-136  Effect of naked reference on KILL command"
 S ^ABSN="20152",^ITEM="II-136  Effect of naked reference on KILL command",^NEXT="137^V2NR,V2READ^VV2" D ^V2PRESET
 S VCOMP=""
 K ^VV,^VV(1) S ^(1)=1 S VCOMP=^VV(1)
 S ^VCOMP=VCOMP,^VCORR="1" D ^VEXAMINE
 ;
137 W !,"II-137  Effect of naked reference on $DATA function"
 S ^ABSN="20153",^ITEM="II-137  Effect of naked reference on $DATA function",^NEXT="138^V2NR,V2READ^VV2" D ^V2PRESET
 S VCOMP=""
 K ^VV S VCOMP=$D(^VV(1))_" " S ^(2)=2 S VCOMP=VCOMP_^VV(2)
 S ^VCOMP=VCOMP,^VCORR="0 2" D ^VEXAMINE
 ;
138 W !,"II-138  Effect of global reference in $DATA on naked indicator"
 S ^ABSN="20154",^ITEM="II-138  Effect of global reference in $DATA on naked indicator",^NEXT="139^V2NR,V2READ^VV2" D ^V2PRESET
 S VCOMP=""
 K ^VV,^VV(1,1) S ^(2)="X" S VCOMP=$D(^(2,3))_" " S ^(4)=3 S VCOMP=VCOMP_^VV(1,2,4)
 S ^VCOMP=VCOMP,^VCORR="0 3" D ^VEXAMINE
 ;
139 W !,"II-139  Interpretation sequence of SET command"
 S ^ABSN="20155",^ITEM="II-139  Interpretation sequence of SET command",^NEXT="V2READ^VV2" D ^V2PRESET
 S VCOMP=""
 K ^VV S ^($D(^VV(0)))=$D(^(0)) S VCOMP=^VV(0)
 S ^VCOMP=VCOMP,^VCORR="0" D ^VEXAMINE
 ;
END W !!,"End of 17---V2NR",!
 K  K ^VV Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
