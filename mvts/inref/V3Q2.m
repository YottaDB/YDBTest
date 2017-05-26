V3Q2 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"39---V3Q2: $QUERY(glvn) -2-"
 W !!,"$QUERY(lvn)  When p=0 and q<0"
 ;
11 S ^ABSN="30394",^ITEM="III-0394  p=0 and q=1"
 S ^NEXT="12^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="",A("a")=""
 S ^VCOMP=$Q(A)
 S ^VCORR="A(""a"")" D ^VEXAMINE
 ;
12 S ^ABSN="30395",^ITEM="III-0395  p=0 and q=2"
 S ^NEXT="13^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="",A("a","b")=""
 S ^VCOMP=$Q(A)
 S ^VCORR="A(""a"",""b"")" D ^VEXAMINE
 ;
13 S ^ABSN="30396",^ITEM="III-0396  p=0 and q=3"
 S ^NEXT="14^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="",A("a","b","c")=""
 S ^VCOMP=$Q(A)
 S ^VCORR="A(""a"",""b"",""c"")" D ^VEXAMINE
 ;
14 S ^ABSN="30397",^ITEM="III-0397  p=0 and q=7"
 S ^NEXT="15^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="",A("a","b","c","d","e","f","g")=""
 S ^VCOMP=$Q(A)
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"")" D ^VEXAMINE
 ;
15 S ^ABSN="30398",^ITEM="III-0398  p=0 and q=10"
 S ^NEXT="16^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c","d",5,6,7,8,9,0)=""
 S ^VCOMP=$Q(A)
 S ^VCORR="A(""a"",""b"",""c"",""d"",5,6,7,8,9,0)" D ^VEXAMINE
 ;
16 S ^ABSN="30399",^ITEM="III-0399  Maximum length variable name"
 S ^NEXT="17^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="abcdefgh",ABCDEFG="",ABCDEFG(A,A,A,A,A,A,A,A,A,A,A,A)=A
 S ^VCOMP=$Q(ABCDEFG)
 s B="ABCDEFG("""_A_"""" f I=1:1:11 s B=B_","""_A_""""
 s B=B_")"
 S ^VCORR=B D ^VEXAMINE
 ;
17 W !!,"When k>0 and k'>min(p,q) and ..."
 ;
 S ^ABSN="30400",^ITEM="III-0400  k=1"
 S ^NEXT="18^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("abcdefgh")="",A("abcdefgi",123)=""
 S ^VCOMP=$Q(A("abcdefgh"))
 S ^VCORR="A(""abcdefgi"",123)" D ^VEXAMINE
 ;
18 S ^ABSN="30401",^ITEM="III-0401  k=2"
 S ^NEXT="19^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","A")="",A("a","a","a")=""
 S ^VCOMP=$Q(A("a","A","a"))
 S ^VCORR="A(""a"",""a"",""a"")" D ^VEXAMINE
 ;
19 S ^ABSN="30402",^ITEM="III-0402  k=3"
 S ^NEXT="20^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","a","a")="",A("a","a","b")=""
 S ^VCOMP=$Q(A("a","a","a"))
 S ^VCORR="A(""a"",""a"",""b"")" D ^VEXAMINE
 ;
20 S ^ABSN="30403",^ITEM="III-0403  k=7"
 S ^NEXT="21^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A(1,2,3,4,5,6,7)=""
 s A(1,2,3,4,5,6,+7.10,8,9,0)=""
 s A(1,2,3,4,5,6,7.2)=""
 S ^VCOMP=$Q(A(1,2,3,4,5,6,7))
 S ^VCORR="A(1,2,3,4,5,6,7.1,8,9,0)" D ^VEXAMINE
 ;
21 S ^ABSN="30404",^ITEM="III-0404  k=12"
 S ^NEXT="22^V3Q2,V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c","d","e","f","g","h","i","j","k","l")=""
 s A("a","b","c","d","e","f","g","h","i","j","k","l1","m")=""
 S ^VCOMP=$Q(A("a","b","c","d","e","f","g","h","i","j","k","l0"))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"",""l1"",""m"")" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
;Accessing more than 32/31 subscripts, cut loops back
; 10/2001 SE
22 S ^ABSN="30405",^ITEM="III-0405  Maximum length variable name"
 S ^NEXT="V3Q3^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="x",B="A(A"
 ;Original line: f I=1:1:41 s B=B_",A"
 f I=1:1:30 s B=B_",A"
 s B=B_")",@B=A
 s C="A(A"
 ;Original line: f I=1:1:40 s C=C_",A"
 f I=1:1:29 s C=C_",A"
 s C=C_",""y"")",@C=A
 S ^VCOMP=$Q(@B)
 ;Original line: s D="A(""x""" f I=1:1:40 s D=D_",""x"""
 s D="A(""x""" f I=1:1:29 s D=D_",""x"""
 s D=D_",""y"")"
 S ^VCORR=D D ^VEXAMINE
 ;
END W !!,"End of 39 --- V3Q2",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
