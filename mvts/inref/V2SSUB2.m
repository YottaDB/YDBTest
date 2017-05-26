V2SSUB2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;STRING SUBSCRIPT -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"26---V2SSUB2: String subscript -2-",!
177 W !,"II-177  Naked reference when the total length of global variable is 63 characters (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20220",^ITEM="II-177  Naked reference when the total length of global variable is 63 characters (max)",^NEXT="178^V2SSUB2,END^VV2" D ^V2PRESET
 W !,"       (This test II-177 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
178 W !,"II-178  Minimum (-.999999999E25) to maximum (.999999999E25) number of one subscript of local variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20221",^ITEM="II-178  Minimum (-.999999999E25) to maximum (.999999999E25) number of one subscript of local variable",^NEXT="179^V2SSUB2,END^VV2" D ^V2PRESET
 W !,"       (This test II-178 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
179 W !,"II-179  Minimum (-.999999999E25) to maximum (.999999999E25) number of one subscript of global variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20222",^ITEM="II-179  Minimum (-.999999999E25) to maximum (.999999999E25) number of one subscript of global variable",^NEXT="180^V2SSUB2,END^VV2" D ^V2PRESET
 W !,"       (This test II-179 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
180 W !,"II-180  Total number of local variable subscripts is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20223",^ITEM="II-180  Total number of local variable subscripts is 31 (max)",^NEXT="181^V2SSUB2,END^VV2" D ^V2PRESET
 W !,"       (This test II-180 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
181 W !,"II-181  Total number of global variable subscripts is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20224",^ITEM="II-181  Total number of global variable subscripts is 31 (max)",^NEXT="END^VV2" D ^V2PRESET
 W !,"       (This test II-181 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 26---V2SSUB2",!
 K  K ^VV,^V Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
