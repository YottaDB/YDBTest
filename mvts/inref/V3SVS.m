V3SVS ;IW-YS-KO-TS,VV3,MVTS V9.10;15/6/96;SPECIAL VARIABLE $STORAGE
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"31---V3SVS: Special variable $STORAGE",!
V3797 W !,"I,III-349  Partition size for assurance of routine transferability (5000 Byte)"
 S ^ABSN="30349",^ITEM="I,III-349  Partition size for assurance of routine transferability (5000 Byte)"
 S ^NEXT="V3SSUB^VV3" D ^V3PRESET
 K
 S ^VCOMP=$S<3200
 S ^VCORR=0 D ^VEXAMINE
 ;
END W !!,"End of 31 --- V3SVS",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
