V2NO2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;$NEXT AND $ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"24---V2NO2: $NEXT and $ORDER  -2-",!
 ;
169 W !!,"$ORDER(glvn)",!
 W !,"II-169  Sequence from an empty string when glvn is lvn"
16911 S ^ABSN="20206",^ITEM="II-169.1.1  Numeric interpretation of a subscript",^NEXT="16912^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test ID tagged in V7.4;16/9/89
 D SETX^V2NOE,SETL^V2NOE S VCOMP="",X=-1E11
 FOR I=1:1:35 S X=$O(A(X)) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(1)_X(2)_X(3) D ^VEXAMINE
 ;
16912 S ^ABSN="20207",^ITEM="II-169.1.2  What is the set A (local)?",^NEXT="16913^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 D SETL2^V2NOE S VCOMP="",X=""
 FOR I=1:1:12 S X=$O(A(X)) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(3) D ^VEXAMINE
 ;
16913 S ^ABSN="20208",^ITEM="II-169.1.3  The last returned value",^NEXT="1692^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 D SETL2^V2NOE S VCOMP="",X=-1E11
 FOR I=1:1 S X=$O(A(X)) S VCOMP=VCOMP_X_" " Q:X=""
 S ^VCOMP=VCOMP,^VCORR=X(4) D ^VEXAMINE
 ;
1692 S ^ABSN="20209",^ITEM="II-169.2  Subscript is one character (95 graphics including space)",^NEXT="170^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 D SETX^V2NOE S VCOMP="",X="" K V1 F I=126:-1:32 S V1($C(I))=""
 S X="" F I=0:0 S X=$O(V1(X)) Q:X=""  S VCOMP=VCOMP_X
 S ^VCOMP=VCOMP,^VCORR=X(4) D ^VEXAMINE
 ;
170 W !,"II-170  Sequence from an empty string when glvn is gvn"
17011 S ^ABSN="20210",^ITEM="II-170.1.1  Numeric interpretation of a subscript",^NEXT="17012^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test ID tagged in V7.4;16/9/89
 D SETX^V2NOE,SETG^V2NOE S VCOMP="",X=""
 F I=1:1:35 S X=$O(^VV(X)) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(1)_X(2)_X(3) D ^VEXAMINE
 ;
17012 S ^ABSN="20211",^ITEM="II-170.1.2  What is the set A (global)?",^NEXT="17013^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 D SETG2^V2NOE S VCOMP="",X=""
 F I=1:1:12 S X=$O(^VV(X)) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(3) D ^VEXAMINE
 ;
17013 S ^ABSN="20212",^ITEM="II-170.1.3  The last returned value",^NEXT="1702^V2NO2,V2SSUB1^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 D SETG2^V2NOE S VCOMP="",X=-1E11
 F I=1:1 S X=$O(^VV(X)) S VCOMP=VCOMP_X_" " Q:X=""
 S ^VCOMP=VCOMP,^VCORR=X(4) D ^VEXAMINE
 ;
1702 S ^ABSN="20213",^ITEM="II-170.2  Subscript is one character (95 graphics including space)",^NEXT="V2SSUB1^VV2" D ^V2PRESET
 S VCOMP="",X=""
 D SETX^V2NOE K ^V1 F I=32:1:126 S ^V1(1,2,3,"ABC","A","B",$C(I))=""
 S X="" F I=0:0 S X=$O(^(X)) q:X=""  S VCOMP=VCOMP_X
 S ^VCOMP=VCOMP,^VCORR=X(4) D ^VEXAMINE
 ;
END W !!,"End of 24---V2NO2",!
 K  K ^VV,^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
