V3ALDO2 ;IW-KO-YS-TS,V3ALDO,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 W !!,"135---V3ALDO2: Argumentless DO command -2-"
1 S ^ABSN="31071",^ITEM="III-1071  QUIT by an implicit QUIT command"
 S ^NEXT="2^V3ALDO2,V3FP^VV3" D ^V3PRESET K
 S ^VCOMP="" d  S ^VCOMP=^VCOMP_"B"
 . S ^VCOMP=^VCOMP_"A"
 . . S ^VCOMP=^VCOMP_"ERROR "
 S ^VCOMP=^VCOMP_"C"
 S ^VCORR="ABC" D ^VEXAMINE
 ;
2 S ^ABSN="31072",^ITEM="III-1072  QUIT by an eor"
 S ^NEXT="3^V3ALDO2,V3FP^VV3" D ^V3PRESET K
 S ^VCOMP="" D EOR
 S ^VCORR="AB" D ^VEXAMINE
 ;
3 S ^ABSN="31073",^ITEM="III-1073  FOR command in an argumnetless DO scope"
 S ^NEXT="4^V3ALDO2,V3FP^VV3" D ^V3PRESET K
 S ^VCOMP="" D  S ^VCOMP=^VCOMP_"/"
 . FOR I=1:1:5  D  S ^VCOMP=^VCOMP_" "  G:I=4 ABC
 . . S ^VCOMP=^VCOMP_I
ABC . S ^VCOMP=^VCOMP_"E"
 S ^VCOMP=^VCOMP_"#"
 S ^VCORR="1 2 3 4 E/#" D ^VEXAMINE
 ;
4 S ^ABSN="31074",^ITEM="III-1074  Nesting of argumentless DO"
 S ^NEXT="V3FP^VV3" D ^V3PRESET K
 S ^VCOMP="" D
 . S ^VCOMP=^VCOMP_"A" D  S ^VCOMP=^VCOMP_"A"
 .. S ^VCOMP=^VCOMP_"B" D  S ^VCOMP=^VCOMP_"B"
 ... S ^VCOMP=^VCOMP_"C" D  S ^VCOMP=^VCOMP_"C"
 .... S ^VCOMP=^VCOMP_"D" D  S ^VCOMP=^VCOMP_"D"
 ..... S ^VCOMP=^VCOMP_"E" D  S ^VCOMP=^VCOMP_"E"
 ...... S ^VCOMP=^VCOMP_"F" D  S ^VCOMP=^VCOMP_"F"
 ....... S ^VCOMP=^VCOMP_"G" D  S ^VCOMP=^VCOMP_"G"
 ........ S ^VCOMP=^VCOMP_"H" D  S ^VCOMP=^VCOMP_"H"
 ......... S ^VCOMP=^VCOMP_"I" D  S ^VCOMP=^VCOMP_"I"
 .......... S ^VCOMP=^VCOMP_"J" D  S ^VCOMP=^VCOMP_"J"
 ........... S ^VCOMP=^VCOMP_"K" D  S ^VCOMP=^VCOMP_"K"
 ............ S ^VCOMP=^VCOMP_"L" D  S ^VCOMP=^VCOMP_"L"
 ............. S ^VCOMP=^VCOMP_"M" D  S ^VCOMP=^VCOMP_"M"
 .............. S ^VCOMP=^VCOMP_"N"
 ............. S ^VCOMP=^VCOMP_"M"
 ............ S ^VCOMP=^VCOMP_"L"
 ........... S ^VCOMP=^VCOMP_"K"
 .......... S ^VCOMP=^VCOMP_"J"
 ......... S ^VCOMP=^VCOMP_"I"
 ........ S ^VCOMP=^VCOMP_"H"
 ....... S ^VCOMP=^VCOMP_"G"
 ...... S ^VCOMP=^VCOMP_"F"
 ..... S ^VCOMP=^VCOMP_"E"
 .... S ^VCOMP=^VCOMP_"D"
 ... S ^VCOMP=^VCOMP_"C"
 .. S ^VCOMP=^VCOMP_"B"
 . S ^VCOMP=^VCOMP_"A"
 S ^VCOMP=^VCOMP_"/"
 S ^VCORR="ABCDEFGHIJKLMNMMLLKKJJIIHHGGFFEEDDCCBBAA/" D ^VEXAMINE
 ;
END W !!,"End of 135 --- V3ALDO2 ",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
EOR D  S ^VCOMP=^VCOMP_"B"
 . S ^VCOMP=^VCOMP_"A"
