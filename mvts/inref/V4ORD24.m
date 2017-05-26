V4ORD24 ;IW-KO-TS-YS,V4ORDER,MVTS V9.10;15/6/96;$ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 W !!,"111---V4ORD24:  $ORDER(glvn,expr)  -4-"
 W !,"glvn=gvn"
 ;
1 S ^ABSN="40699",^ITEM="IV-699  subscript is one character (95 graphics including space)"
 S ^NEXT="2^V4ORD24,V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S VCOMP="",X=""
 F I=32:1:126 S ^V($C(I))=""
 S X="" F  S X=$O(^V(X),-1) Q:X=""  S VCOMP=VCOMP_X
 S X="" F I=126:-1:58 S X=X_$C(I)
 S X=X_"/.-,+*)('&%$#""! 9876543210"
 S ^VCOMP=VCOMP,^VCORR=X D ^VEXAMINE K ^V
 ;
2 S ^ABSN="40700",^ITEM="IV-700  sequence from an empty string"
 S ^NEXT="3^V4ORD24,V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP="",^V(-192)=-192,^V(-1)=-1,^V(0)=0,^V(839)=839,^V("AAA")="AAA"
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 K ^V("AAA")
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 K ^V(839)
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 K ^V(0)
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 K ^V(-1)
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 K ^V(-192)
 S ^VCOMP=^VCOMP_$O(^V(""),-1)_" "
 S ^VCORR="AAA 839 0 -1 -192  " D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40701",^ITEM="IV-701  numeric interpretation of a subscript"
 S ^NEXT="4^V4ORD24,V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 D SETX^V4ORDE,SETG^V4ORDE S VCOMP="",X="~~~~~~~~"
 FOR I=1:1:35 S X=$O(^V(X),-1) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(-3)_X(-2)_X(-1) D ^VEXAMINE K ^V
 ;
4 S ^ABSN="40702",^ITEM="IV-702  sequence from an empty string when glvn is gvn"
 S ^NEXT="5^V4ORD24,V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 D SETX^V4ORDE,SETG^V4ORDE S VCOMP="",X=""
 FOR I=1:1:35 S X=$O(^V(X),-1) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(-3)_X(-2)_X(-1) D ^VEXAMINE K ^V
 ;
5 S ^ABSN="40703",^ITEM="IV-703  what is the set A (global)?"
 S ^NEXT="6^V4ORD24,V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 D SETG2^V4ORDE S VCOMP="",X=""
 FOR I=1:1:12 S X=$O(^V(X),-1) S VCOMP=VCOMP_X_" "
 S ^VCOMP=VCOMP,^VCORR=X(-3) D ^VEXAMINE K ^V
 ;
6 S ^ABSN="40704",^ITEM="IV-704  the last returned value"
 S ^NEXT="V4ORD25^V4ORDER,V4QUERY^VV4" D ^V4PRESET K  K ^V
 D SETG2^V4ORDE S VCOMP="",X=""
 FOR I=1:1 S X=$O(^V(X),-1) S VCOMP=VCOMP_X_" " Q:X=""
 S ^VCOMP=VCOMP,^VCORR=X(-4) D ^VEXAMINE K ^V
 ;
END W !!,"End of 111 --- V4ORD24",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
