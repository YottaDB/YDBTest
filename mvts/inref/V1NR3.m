V1NR3 ;IW-YS-TS,V1NR,MVTS V9.10;15/6/96;NAKED REFERENCE -3-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"118---V1NR3: Naked references on gvn -3-",!
 ;
848 W !,"I-848  Naked indicator not affected by setting lvn=strlit"
 ;(Test added in V7.5;20/12/89)
 S ^ABSN="11547",^ITEM="I-848  Naked indicator not affected by setting lvn=strlit",^NEXT="849^V1NR3,V1NX^VV1" D ^V1PRESET
 S VCOMP="" K ^V S ^V(1,2,3,4)="1234 ",^(5)="1235 "
 S V(3,2,1)="321 " S ^(12.5)="12.5 "
 S VCOMP=^(4)_^(5)_^(12.5)_^V(1,2,3,4)_^V(1,2,3,5)_^V(1,2,3,12.5)_V(3,2,1)
 K ^V S ^VCOMP=VCOMP,^VCORR="1234 1235 12.5 1234 1235 12.5 321 " D ^VEXAMINE
 ;
849 W !,"I-849  Naked indicator not affected by setting lvn=lvn"
 ;(Test added in V7.5;20/12/89)
 S ^ABSN="11548",^ITEM="I-849  Naked indicator not affected by setting lvn=lvn",^NEXT="850^V1NR3,V1NX^VV1" D ^V1PRESET
 S ABC(123)="ABC ",VCOMP=""
 K ^V S ^V(1,2,3,4)="1234 ",^(5)="1235 "
 S V(1,2)=ABC(123) S ^("DEF")="DEF "
 S VCOMP=^(4)_^(5)_^("DEF")_^V(1,2,3,4)_^V(1,2,3,5)_^V(1,2,3,"DEF")_V(1,2)
 K ^V S ^VCOMP=VCOMP,^VCORR="1234 1235 DEF 1234 1235 DEF ABC " D ^VEXAMINE
 ;
850 W !,"I-850  If KILL of lvn affects naked indicator"
 ;(Test added in V7.5;20/12/89)
 S ^ABSN="11549",^ITEM="I-850  If KILL of lvn affects naked indicator",^NEXT="851^V1NR3,V1NX^VV1" D ^V1PRESET
 S VCOMP="" S VV(1,2)="12 ",^VV(0,1,1,1)="A " S VCOMP=^(1)
 KILL VV(1)
 S VCOMP=VCOMP_^(1) S ^(2)="B ",VCOMP=VCOMP_^(2)_^VV(0,1,1,1)_^VV(0,1,1,2)_$D(VV)
 K ^VV S ^VCOMP=VCOMP,^VCORR="A A B A B 0" D ^VEXAMINE
 ;
851 W !,"I-851  If LOCK of lvn affects naked indicator"
 ;(Test added in V7.5;20/12/89)
 S ^ABSN="11550",^ITEM="I-851  If LOCK of lvn affects naked indicator",^NEXT="V1NX^VV1" D ^V1PRESET
 S VCOMP="" S ^VV(12,34,56)="X "
 L VV
 S VCOMP=VCOMP_^(56) S ^(1)="Y " S VCOMP=VCOMP_^(1)_^VV(12,34,56)_^VV(12,34,1)
 K ^VV L  S ^VCOMP=VCOMP,^VCORR="X Y X Y " D ^VEXAMINE
 ;
END W !!,"End of 118---V1NR3",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
