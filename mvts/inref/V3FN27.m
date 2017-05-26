V3FN27 ;IW-KO-YS-TS,V3FN2,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"50---V3FN27: $FNUMBER(numexpr,fncodexpr)  -7-"
 W !!,"fncodexpr is an empty string"
 ;
88 S ^ABSN="30539",^ITEM="III-0539  numexpr=01.2340"
 S ^NEXT="89^V3FN27,V3FN28^V3FN2,V3FN3^VV3" D ^V3PRESET
 ;S ^VCOMP=$FN(01.2340,"")
 ;S ^VCORR="1.234" D ^VEXAMINE
 W !,"   (This test ",^ITEM," was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
89 S ^ABSN="30540",^ITEM="III-0540  numexpr=-01.2340"
 S ^NEXT="90^V3FN27,V3FN28^V3FN2,V3FN3^VV3" D ^V3PRESET
 ;S ^VCOMP=$FN(-01.2340,"")
 ;S ^VCORR="-1.234" D ^VEXAMINE
 W !,"   (This test ",^ITEM," was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
90 S ^ABSN="30541",^ITEM="III-0541  numexpr=""01.2340"""
 S ^NEXT="91^V3FN27,V3FN28^V3FN2,V3FN3^VV3" D ^V3PRESET
 ;S ^VCOMP=$FN("01.2340","")
 ;S ^VCORR="1.234" D ^VEXAMINE
 W !,"   (This test ",^ITEM," was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
91 S ^ABSN="30542",^ITEM="III-0542  numexpr=""-01.2340"""
 S ^NEXT="V3FN28^V3FN2,V3FN3^VV3" D ^V3PRESET
 ;S ^VCOMP=$FN("-01.2340","")
 ;S ^VCORR="-1.234" D ^VEXAMINE
 W !,"   (This test ",^ITEM," was withdrawn in 15/2/1994 on X11.1-1990, MSL)"
 S ^VREPORT("Part-90",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 50 --- V3FN27",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
