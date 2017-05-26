V3Q4 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"41---V3Q4: $QUERY(glvn) -4-"
 W !!,"$QUERY(gvn)  When p=0 and q<0"
 ;
33 S ^ABSN="30416",^ITEM="III-0416  p=0 and q=1"
 S ^NEXT="34^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV="",^VV("a")=""
 S ^VCOMP=$Q(^VV)
 S ^VCORR="^VV(""a"")" D ^VEXAMINE K ^VV
 ;
34 S ^ABSN="30417",^ITEM="III-0417  p=0 and q=2"
 S ^NEXT="35^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV="",^VV("a","b")=""
 S ^VCOMP=$Q(^VV)
 S ^VCORR="^VV(""a"",""b"")" D ^VEXAMINE K ^VV
 ;
35 S ^ABSN="30418",^ITEM="III-0418  p=0 and q=3"
 S ^NEXT="36^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV="",^VV("a","b","c")=""
 S ^VCOMP=$Q(^VV)
 S ^VCORR="^VV(""a"",""b"",""c"")" D ^VEXAMINE K ^VV
 ;
36 S ^ABSN="30419",^ITEM="III-0419  p=0 and q=7"
 S ^NEXT="37^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV="",^VV("a","b","c","d","e","f","g")=""
 S ^VCOMP=$Q(^VV)
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"",""f"",""g"")" D ^VEXAMINE K ^VV
 ;
37 S ^ABSN="30420",^ITEM="III-0420  p=0 and q=10"
 S ^NEXT="38^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c","d",5,6,7,8,9,0)=""
 S ^VCOMP=$Q(^VV)
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",5,6,7,8,9,0)" D ^VEXAMINE K ^VV
 ;
38 S ^ABSN="30421",^ITEM="III-0421  Maximum length variable name"
 S ^NEXT="39^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VVABCDE s A="abcdefgh",^VVABCDE="",^VVABCDE(A,A,A,A,A,A,A,A,A,A,A,A)=A
 S ^VCOMP=$Q(^VVABCDE)
 s B="^VVABCDE("""_A_"""" f I=1:1:11 s B=B_","""_A_""""
 s B=B_")"
 S ^VCORR=B D ^VEXAMINE k ^VVABCDE K ^VVABCDE
 ;
39 W !!,"When k>0 and k'>min(p,q) and ..."
 ;
 S ^ABSN="30422",^ITEM="III-0422  k=1"
 S ^NEXT="40^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("abcdefgh")="",^VV("abcdefgi",123)=""
 S ^VCOMP=$Q(^VV("abcdefgh"))
 S ^VCORR="^VV(""abcdefgi"",123)" D ^VEXAMINE K ^VV
 ;
40 S ^ABSN="30423",^ITEM="III-0423  k=2"
 S ^NEXT="41^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","A")="",^VV("a","a","a")=""
 S ^VCOMP=$Q(^VV("a","A","b"))
 S ^VCORR="^VV(""a"",""a"",""a"")" D ^VEXAMINE K ^VV
 ;
41 S ^ABSN="30424",^ITEM="III-0424  k=3"
 S ^NEXT="42^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","a","a")="",^VV("a","a","b")=""
 S ^VCOMP=$Q(^VV("a","a","abc"))
 S ^VCORR="^VV(""a"",""a"",""b"")" D ^VEXAMINE K ^VV
 ;
42 S ^ABSN="30425",^ITEM="III-0425  k=7"
 S ^NEXT="43^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV(1,2,3,4,5,6,7)=""
 s ^VV(1,2,3,4,5,6,+7.10,8,9,0)=""
 s ^VV(1,2,3,4,5,6,7.2)=""
 S ^VCOMP=$Q(^VV(1,2,3,4,5,6,7))
 S ^VCORR="^VV(1,2,3,4,5,6,7.1,8,9,0)" D ^VEXAMINE K ^VV
 ;
43 S ^ABSN="30426",^ITEM="III-0426  k=12"
 S ^NEXT="44^V3Q4,V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c","d","e","f","g","h","i","j","k","l")=""
 s ^VV("a","b","c","d","e","f","g","h","i","j","k","l1","m")=""
 S ^VCOMP=$Q(^VV("a","b","c","d","e","f","g","h","i","j","k","l0"))
 S ^VCORR="^VV(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"",""l1"",""m"")" D ^VEXAMINE K ^VV
 ;
; **MVTS LOCAL CHANGE**
; exceeds GT.M's max subscripts (31)
; 10/2001 SE
44 S ^ABSN="30427",^ITEM="III-0427  Maximum length variable name"
 S ^NEXT="V3Q5^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VVAB s A="x",B="^VVAB(A"
 ; Original line: f I=1:1:40 s B=B_",A"
 f I=1:1:29 s B=B_",A"
 s B=B_")",@B=A
 s C="^VVAB(A"
 ; Original line: f I=1:1:39 s C=C_",A"
 f I=1:1:28 s C=C_",A"
 s C=C_",""y"")",@C=A
 S ^VCOMP=$Q(@B)
 ; Original line: s D="^VVAB(""x""" f I=1:1:39 s D=D_",""x"""
 s D="^VVAB(""x""" f I=1:1:28 s D=D_",""x"""
 s D=D_",""y"")"
 S ^VCORR=D D ^VEXAMINE k ^VVAB
 ;
END W !!,"End of 41 --- V3Q4",!
 K  K ^VV,^VVABCDE,^VVAB Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
