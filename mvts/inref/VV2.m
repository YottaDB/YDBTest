VV2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;PART-84 DRIVER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
START ;
 I $D(^VENVIRON("INTEGRITY"))=0 D ^VINT9
 I ^VENVIRON("INTEGRITY")="OK" G START1
 I ^VENVIRON("INTEGRITY")="NOT OK" G START1
 D ^VINT9
START1 ;
 I $D(^VENVIRON("COMPLETE"))=1 D EDIT^VENVIRON
 I $D(^VENVIRON("COMPLETE"))=0 D ^VENVIRON
 S ^VREPORT="Part-84"
 K ^VREPORT("Part-84")
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 W #,"*** Standard MUMPS Validation Test Suite Version 9.10, Part-84 (DRIVER) ***"
 W !,"    ( The last Test ID number for Part-84 is II-182. )",!!
V2CS W !!,"1---V2CS" D ^V2CS ;Command space
V2LCC1 W !!,"2---V2LCC1" D ^V2LCC1 ;Lower case command words and $data -1-
V2LCC2 W !!,"3---V2LCC2" D ^V2LCC2 ;Lower case command words and $data -2-
V2LCF1 W !!,"4---V2LCF1" D ^V2LCF1 ;Lower case function names (less $data) and special variable names -1-
V2LCF2 W !!,"5---V2LCF2" D ^V2LCF2 ;Lower case function names (less $data) and special variable names -2-
V2LCF3 W !!,"6---V2LCF3" D ^V2LCF3 ;Lower case function names (less $data) and special variable names -3-
V2LCF4 W !!,"7---V2LCF4" D ^V2LCF4 ;Lower case function names (less $data) and special variable names -4-
V2FN1 W !!,"8---V2FN1" D ^V2FN1 ;Functions extended -1-
V2FN2 W !!,"9---V2FN2" D ^V2FN2 ;Functions extended -2-
V2LHP1 W !!,"10---V2LHP1" D ^V2LHP1 ;Left hand $PIECE -1-
V2LHP2 W !!,"11---V2LHP2" D ^V2LHP2 ;Left hand $PIECE -2-
V2LHP3 W !!,"12---V2LHP3" D ^V2LHP3 ;Left hand $PIECE -3-
V2LHP4 W !!,"13---V2LHP4" D ^V2LHP4 ;Left hand $PIECE -4-
V2VNIA W !!,"14---V2VNIA" D ^V2VNIA ;Variable name indirection -1-
V2VNIB W !!,"15---V2VNIB" D ^V2VNIB ;Variable name indirection -2-
V2VNIC W !!,"16---V2VNIC" D ^V2VNIC ;Variable name indirection -3-
V2NR W !!,"17---V2NR" D ^V2NR ;Naked reference
;V2READ W !!,"18---V2READ" D ^V2READ ;Read count
V2PAT1 W !!,"19---V2PAT1" D ^V2PAT1 ;Pattern match -1-
V2PAT2 W !!,"20---V2PAT2" D ^V2PAT2 ;Pattern match -2-
V2PAT3 W !!,"21---V2PAT3" D ^V2PAT3 ;Pattern match -3-
V2PAT4 W !!,"22---V2PAT4" D ^V2PAT4 ;Pattern match -4-
V2NO1 W !!,"23---V2NO1" D ^V2NO1 ;$NEXT and $ORDER -1-
V2NO2 W !!,"24---V2NO2" D ^V2NO2 ;$NEXT and $ORDER -2-
V2SSUB1 W !!,"25---V2SSUB1" D ^V2SSUB1 ;String subscript -1-
V2SSUB2 W !!,"26---V2SSUB2" D ^V2SSUB2 ;String subscript -2-
END W !,"*** Standard MUMPS Test Validation Suite Version 9.10, Part-84 END ***",!!
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
