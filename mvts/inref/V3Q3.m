V3Q3 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"40---V3Q3: $QUERY(glvn) -3-"
 W !!,"$QUERY(gvn)  When p<q and ik=jk for all k in the range (0<k'>p)"
 ;
23 S ^ABSN="30406",^ITEM="III-0406  p=1 and q=2"
 S ^NEXT="24^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a")="",^VV("a","b")=""
 S ^VCOMP=$QUERY(^VV("a"))
 S ^VCORR="^VV(""a"",""b"")" D ^VEXAMINE k ^VV
 ;
24 S ^ABSN="30407",^ITEM="III-0407  p=1 and q=5"
 S ^NEXT="25^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a")="",^VV("a","b","c","d","e")=""
 S ^VCOMP=$query(^VV("a"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"")" D ^VEXAMINE k ^VV
 ;
25 S ^ABSN="30408",^ITEM="III-0408  p=1 and q=10"
 S ^NEXT="26^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a")="",^VV("a","a","a","a","a","a","a","a","a","a")=""
 S ^VCOMP=$Q(^VV("a"))
 S ^VCORR="^VV(""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"")" D ^VEXAMINE k ^VV
 ;
26 S ^ABSN="30409",^ITEM="III-0409  p=2 and q=3"
 S ^NEXT="27^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b")="",^VV("a","b","c")=""
 S ^VCOMP=$q(^VV("a","b"))
 S ^VCORR="^VV(""a"",""b"",""c"")" D ^VEXAMINE k ^VV
 ;
27 S ^ABSN="30410",^ITEM="III-0410  p=2 and q=4"
 S ^NEXT="28^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b")="",^VV("a","b","c","d")=""
 S ^VCOMP=$Q(^VV("a","b"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"")" D ^VEXAMINE k ^VV
 ;
28 S ^ABSN="30411",^ITEM="III-0411  p=2 and q=10"
 S ^NEXT="29^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","a")="",^VV("a","a","a","a","a","a","a","a","a","a")=""
 S ^VCOMP=$Q(^VV("a","a"))
 S ^VCORR="^VV(""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"")" D ^VEXAMINE K ^VV
 ;
29 S ^ABSN="30412",^ITEM="III-0412  p=8 and q=9"
 S ^NEXT="30^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c","d","e","f","g","h")=""
 s ^VV("a","b","c","d","e","f","g","h","i")=""
 S ^VCOMP=$Q(^VV("a","b","c","d","e","f","g","h"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"")" D ^VEXAMINE K ^VV
 ;
30 S ^ABSN="30413",^ITEM="III-0413  p=8 and q=11"
 S ^NEXT="31^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c","d","e","f","g","h")=""
 s ^VV("a","b","c","d","e","f","g","h","i","j","k")=""
 S ^VCOMP=$Q(^VV("a","b","c","d","e","f","g","h"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"")" D ^VEXAMINE K ^VV
 ;
31 S ^ABSN="30414",^ITEM="III-0414  p=8 and q=20"
 S ^NEXT="32^V3Q3,V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c","d","e","f","g","h")=""
 s ^VV("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t")=""
 S ^VCOMP=$Q(^VV("a","b","c","d","e","f","g","h","i"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"",""l"",""m"",""n"",""o"",""p"",""q"",""r"",""s"",""t"")" D ^VEXAMINE K ^VV
 ;
32 S ^ABSN="30415",^ITEM="III-0415  Maximum length variable name"
 S ^NEXT="V3Q4^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s A="abcdefghijklmnopqrstuvw",^VV(A,A,A,A)=A,^VV(A,A,A,A,A)=A
 S ^VCOMP=$Q(^VV(A,A,A,A))
 s B="^VV("""_A_"""" f I=1:1:4 s B=B_","""_A_""""
 s B=B_")"
 S ^VCORR=B D ^VEXAMINE K ^VV
 ;
END W !!,"End of 40 --- V3Q3",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
