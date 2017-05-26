V3Q1 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 W !!,"38---V3Q1: $QUERY(glvn) -1-"
 W !!,"$QUERY(lvn)  When p<q and ik=jk for all k in the range (0<k'>p)"
 ;
1 S ^ABSN="30384",^ITEM="III-0384  p=1 and q=2"
 S ^NEXT="2^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a")="",A("a","b")=""
 S ^VCOMP=$QUERY(A("a"))
 S ^VCORR="A(""a"",""b"")" D ^VEXAMINE
 ;
2 S ^ABSN="30385",^ITEM="III-0385  p=1 and q=5"
 S ^NEXT="3^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a")="",A("a","b","c","d","e")=""
 S ^VCOMP=$query(A("a"))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"")" D ^VEXAMINE
 ;
3 S ^ABSN="30386",^ITEM="III-0386  p=1 and q=10"
 S ^NEXT="4^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a")="",A("a","a","a","a","a","a","a","a","a","a")=""
 S ^VCOMP=$Q(A("a"))
 S ^VCORR="A(""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"")" D ^VEXAMINE
 ;
4 S ^ABSN="30387",^ITEM="III-0387  p=2 and q=3"
 S ^NEXT="5^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b")="",A("a","b","c")=""
 S ^VCOMP=$q(A("a","b"))
 S ^VCORR="A(""a"",""b"",""c"")" D ^VEXAMINE
 ;
5 S ^ABSN="30388",^ITEM="III-0388  p=2 and q=4"
 S ^NEXT="6^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b")="",A("a","b","c","d")=""
 S ^VCOMP=$Q(A("a","b"))
 S ^VCORR="A(""a"",""b"",""c"",""d"")" D ^VEXAMINE
 ;
6 S ^ABSN="30389",^ITEM="III-0389  p=2 and q=10"
 S ^NEXT="7^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","a")="",A("a","a","a","a","a","a","a","a","a","a")=""
 S ^VCOMP=$Q(A("a","a"))
 S ^VCORR="A(""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"")" D ^VEXAMINE
 ;
7 S ^ABSN="30390",^ITEM="III-0390  p=8 and q=9"
 S ^NEXT="8^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c","d","e","f","g","h")=""
 s A("a","b","c","d","e","f","g","h","i")=""
 S ^VCOMP=$Q(A("a","b","c","d","e","f","g","h"))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"")" D ^VEXAMINE
 ;
8 S ^ABSN="30391",^ITEM="III-0391  p=8 and q=11"
 S ^NEXT="9^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c","d","e","f","g","h")=""
 s A("a","b","c","d","e","f","g","h","i","j","k")=""
 S ^VCOMP=$Q(A("a","b","c","d","e","f","g","h"))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"")" D ^VEXAMINE
 ;
9 S ^ABSN="30392",^ITEM="III-0392  p=8 and q=20"
 S ^NEXT="10^V3Q1,V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c","d","e","f","g","h")=""
 s A("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t")=""
 S ^VCOMP=$Q(A("a","b","c","d","e","f","g","h","i"))
 S ^VCORR="A(""a"",""b"",""c"",""d"",""e"",""f"",""g"",""h"",""i"",""j"",""k"",""l"",""m"",""n"",""o"",""p"",""q"",""r"",""s"",""t"")" D ^VEXAMINE
 ;
10 S ^ABSN="30393",^ITEM="III-0393  Maximum length variable name"
 S ^NEXT="V3Q2^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A="abcdefghijklmnop",A(A,A,A,A,A)=A,A(A,A,A,A,A,A,A)=A
 S ^VCOMP=$Q(A(A,A,A,A,A))
 s B="A("""_A_"""" f I=1:1:6 s B=B_","""_A_""""
 s B=B_")"
 S ^VCORR=B D ^VEXAMINE
 ;
END W !!,"End of 38 --- V3Q1",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
