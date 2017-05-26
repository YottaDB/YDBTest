V2LHP2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LEFT HAND $PIECE -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"11---V2LHP2: Left hand $PIECE -2-",!
 ;
102 W !,"II-102  intexpr2-1<intexpr3<=K"
1021 S ^ABSN="20109",^ITEM="II-102.1  K=1",^NEXT="1022^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 S VCOMP="A^B^C",$P(VCOMP,"B",1,1)="%%"
 S ^VCOMP=VCOMP,^VCORR="%%B^C" D ^VEXAMINE
 ;
1022 S ^ABSN="20110",^ITEM="II-102.2  K=2",^NEXT="1023^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 S VCOMP="A^B^C",$P(VCOMP,"^",2,2)="D"
 S ^VCOMP=VCOMP,^VCORR="A^D^C" D ^VEXAMINE
 ;
1023 S ^ABSN="20111",^ITEM="II-102.3  K=5",^NEXT="103^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 S ^V("A")="A^^B^^C^^D^^E^^F",$P(^V("A"),"^^",2,4)="1"
 S ^VCOMP=^V("A") S ^VCORR="A^^1^^E^^F" D ^VEXAMINE
 ;
103 W !,"II-103  $D(glvn)=0 and intexpr3<1"
 S ^ABSN="20112",^ITEM="II-103  $D(glvn)=0 and intexpr3<1",^NEXT="104^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 K X S $P(X,"^",0,-1)="A",^VCOMP=$D(X),^VCORR="0" D ^VEXAMINE
 ;
104 W !,"II-104  $D(glvn)=0 and intexpr2>intexpr3"
 S ^ABSN="20113",^ITEM="II-104  $D(glvn)=0 and intexpr2>intexpr3",^NEXT="105^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 K ^V S $P(^V,"^",3,2)=1,^VCOMP=$D(^V),^VCORR="0" D ^VEXAMINE
 ;
105 W !,"II-105  $D(glvn)=0 and intexpr3>intexpr2>1"
 S ^ABSN="20114",^ITEM="II-105  $D(glvn)=0 and intexpr3>intexpr2>1",^NEXT="106^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 K X S $P(X,"^",2,3)=$D(X),^VCOMP=X,^VCORR="^0" D ^VEXAMINE
 ;
106 W !,"II-106  intexpr2<1"
 S ^ABSN="20115",^ITEM="II-106  intexpr2<1",^NEXT="107^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 S VCOMP="" S X="A/B/C",$P(X,"/",-3,2)="D" S VCOMP=VCOMP_X_" "
 S X="A/B/C",$P(X,"/",-99999,33)="D" S VCOMP=VCOMP_X
 S ^VCOMP=VCOMP,^VCORR="D/C D" D ^VEXAMINE
 ;
107 W !,"II-107  glvn is naked reference"
 S ^ABSN="20116",^ITEM="II-107  glvn is naked reference",^NEXT="108^V2LHP2,V2LHP3^VV2" D ^V2PRESET
 W !,"       (This test II-107 was withdrawn in 10/10/1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
108 W !,"II-108  Interpretation sequence of subscripted left hand $PIECE"
 S ^ABSN="20117",^ITEM="II-108  Interpretation sequence of subscripted left hand $PIECE",^NEXT="V2LHP3^VV2" D ^V2PRESET
 W !,"       (This test II-108 was withdrawn in 10/10/1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 11---V2LHP2",!
 K  K ^V
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
