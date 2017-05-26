V2LHP3 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LEFT HAND $PIECE -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"12---V2LHP3: Left hand $PIECE -2-",!
109 W !,"II-109  If setpiece on gvn affects naked indicator when intexpr2>intexpr3"
 ;(title changed in V7.5;20/12/89)
 S ^ABSN="20118",^ITEM="II-109  If setpiece on gvn affects naked indicator when intexpr2>intexpr3",^NEXT="110^V2LHP3,V2LHP4^VV2" D ^V2PRESET
 W !,"       (This test II-109 was withdrawn in 10/10/1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
110 W !,"II-110  If setpiece on gvn affects naked indicator when intexpr3<1"
 ;(title changed in V7.5;20/12/89)
 S ^ABSN="20119",^ITEM="II-110  If setpiece on gvn affects naked indicator when intexpr3<1",^NEXT="182^V2LHP3,V2LHP4^VV2" D ^V2PRESET
 W !,"       (This test II-110 was withdrawn in 10/10/1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
182 W !,"II-182  If setpiece on lvn affects naked indicator"
 ;(Test added in V7.5;20/12/89)
 S ^ABSN="20120",^ITEM="II-182  If setpiece on lvn affects naked indicator",^NEXT="111^V2LHP3,V2LHP4^VV2" D ^V2PRESET
 W !,"       (This test II-182 was withdrawn in 10/10/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
111 W !,"II-111  Lower case left hand ""$piece"""
 S ^ABSN="20121",^ITEM="II-111  Lower case left hand ""$piece""",^NEXT="112^V2LHP3,V2LHP4^VV2" D ^V2PRESET
 S VCOMP=""
 S X="A^B^C",$piece(X,"^")="D" S VCOMP=VCOMP_X_" "
 S X="A^B^C",$p(X,"^",3)="D" S VCOMP=VCOMP_X_" "
 S X="A^B^C",$piECE(X,"^",2,1)="D" S VCOMP=VCOMP_X
 S ^VCOMP=VCOMP,^VCORR="D^B^C A^B^D A^B^C" D ^VEXAMINE
 ;
112 W !,"II-112  Left hand $PIECE with postcondition"
 S ^ABSN="20122",^ITEM="II-112  Left hand $PIECE with postcondition",^NEXT="113^V2LHP3,V2LHP4^VV2" D ^V2PRESET
 S VCOMP="" K X
 S:$D(X)=0 X="A**B**C",$PIECE(X,"**",2)="D" S VCOMP=VCOMP_X_" "
 S:$D(X)=0 $P(X,"**",2)="E" S VCOMP=VCOMP_X
 S ^VCOMP=VCOMP,^VCORR="A**D**C A**D**C" D ^VEXAMINE
 ;
113 W !,"II-113  Indirection of left hand $PIECE"
 S ^ABSN="20123",^ITEM="II-113  Indirection of left hand $PIECE",^NEXT="V2LHP4^VV2" D ^V2PRESET
 S VCOMP=""
 S X="A---B---CDEFG---H",Y="---",Z="$P(X,Y,2,3)=123",@Z S VCOMP=VCOMP_X_" "
 S A="C",C="A^B^C^D^E^F",B="D",D="^",$P(@A,@B,3,4)="G" S VCOMP=VCOMP_@A
 S ^VCOMP=VCOMP,^VCORR="A---123---H A^B^G^E^F" D ^VEXAMINE
 ;
END W !!,"End of 12---V2LHP3",!
 K  K ^V Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
