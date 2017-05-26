V2SSUB1 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;STRING SUBSCRIPT -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"25---V2SSUB1: String subscript -1-",!
171 W !,"II-171  Primitive sequence of subs lvn"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20214",^ITEM="II-171  Primitive sequence of subs lvn",^NEXT="172^V2SSUB1,V2SSUB2^VV2" D ^V2PRESET
 S VCOMP="" FOR I=126:-1:32 S A($C(I))=$C(I)
 S X="" F I=1:1 S Y=$O(A(X)) Q:Y=""  S VCOMP=VCOMP_($A(Y)-$A(X)) S X=Y
 S ^VCOMP=VCOMP,^VCORR="49111111111-25" F I=1:1:85 S ^VCORR=^VCORR_1
 D ^VEXAMINE
 ;
172 W !,"II-172  Primitive sequence of subs gvn"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20215",^ITEM="II-172  Primitive sequence of subs gvn",^NEXT="173^V2SSUB1,V2SSUB2^VV2" D ^V2PRESET
 S VCOMP="" K ^VV F I=32:1:126 S ^VV($C(I))=$C(I)
 S X="" F I=1:1 S Y=$O(^VV(X)) Q:Y=""  S VCOMP=VCOMP_($A(Y)-$A(X)) S X=Y
 S ^VCOMP=VCOMP,^VCORR="49111111111-25" F I=1:1:85 S ^VCORR=^VCORR_1
 D ^VEXAMINE
 ;
173 W !,"II-173  Length of one subscript of a local variable is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20216",^ITEM="II-173  Length of one subscript of a local variable is 31 (max)",^NEXT="174^V2SSUB1,V2SSUB2^VV2" D ^V2PRESET
 W !,"       (This test II-173 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
174 W !,"II-174  Total length of a local variable is 63 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20217",^ITEM="II-174  Total length of a local variable is 63 (max)",^NEXT="175^V2SSUB1,V2SSUB2^VV2" D ^V2PRESET
 W !,"       (This test II-174 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
175 W !,"II-175  Length of one subscript of a global variable is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20218",^ITEM="II-175  Length of one subscript of a global variable is 31 (max)",^NEXT="176^V2SSUB1,V2SSUB2^VV2" D ^V2PRESET
 W !,"       (This test II-175 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
176 W !,"II-176  Total length of a global variable is 63 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="20219",^ITEM="II-176  Total length of a global variable is 63 (max)",^NEXT="V2SSUB2^VV2" D ^V2PRESET
 W !,"       (This test II-176 was withdrawn in 1992 on X11.1-1990, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 25---V2SSUB1",!
 K  K ^VV Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
