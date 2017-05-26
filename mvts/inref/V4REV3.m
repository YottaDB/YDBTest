V4REV3 ;IW-KO-YS-TS,V4REV,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"21---V4REV3:  $REVERSE function  -3-"
 ;
 W !,"expr contains functions"
 ;
1 S ^ABSN="40169",^ITEM="IV-169  expr contains a $ORDER function"
 S ^NEXT="2^V4REV3,V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET K VV,^VV
 S VV("KFLR456")="",VV("456")=""
 S ^VV("KFLR456")="",^VV("456")=""
 S ^VCOMP=$RE($O(VV("")))_" "_$RE($O(VV($O(VV("")))))_"/"
 S ^VCOMP=^VCOMP_$RE($O(^VV("")))_" "_$RE($O(^VV($O(^VV("")))))
 S ^VCORR="654 654RLFK/654 654RLFK" D ^VEXAMINE K VV,^VV
 ;
2 S ^ABSN="40170",^ITEM="IV-170  expr contains a $GET function"
 S ^NEXT="3^V4REV3,V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET
 K VV
 S ^VCOMP=$re($G(VV(3,4,5)))
 S ^VCORR="" D ^VEXAMINE
 ;
3 S ^ABSN="40171",^ITEM="IV-171  expr contains extrinsic special variable"
 S ^NEXT="4^V4REV3,V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET
 K VV S VV("abcdefghijklmnopqrstuvwxyz")="123"
 S ^VCOMP=$RE($$VVNEXT)
 S ^VCORR="zyxwvutsrqponmlkjihgfedcba" D ^VEXAMINE
 ;
4 S ^ABSN="40172",^ITEM="IV-172  expr contains extrinsic function"
 S ^NEXT="5^V4REV3,V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET
 S ^VCOMP=$re($$REV("NAMEname"))
 S ^VCORR="NAMEname" D ^VEXAMINE
 ;
5 S ^ABSN="40173",^ITEM="IV-173  expr contains nested functions"
 S ^NEXT="6^V4REV3,V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET
 S ^VCOMP=$re($REVERSE("abcdefghijklmnopqrstuvwxyz")_3.1E-00)
 S ^VCORR="1.3abcdefghijklmnopqrstuvwxyz" D ^VEXAMINE
 ;
 W !,"expr has indirections"
 ;
6 S ^ABSN="40174",^ITEM="IV-174  ^VV(@A)"
 S ^NEXT="V4REV4^V4REV,V4GET2^VV4" D ^V4PRESET K A,^VV,B
 S A="B(0)",B(0)="56.78",^VV(B(0))="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 S ^VCOMP=$RE(^VV(@A))
 S ^VCORR="ZYXWVUTSRQPONMLKJIHGFEDCBA" D ^VEXAMINE K ^VV
 ;
END W !!,"End of 21 --- V4REV3",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
VVNEXT() Q $O(VV(""))
 ;
REV(E) Q $S(E="":"",1:$$REV($E(E,2,$L(E)))_$E(E,1))
 ; 
