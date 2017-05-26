V3Q6 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"43---V3Q6: $QUERY(glvn) -6-"
 W !!,"Value of $Q is an empty string"
 ;
57 S ^ABSN="30440",^ITEM="III-0440  lvn is undefined"
 S ^NEXT="58^V3Q6,V3FN2^VV3" D ^V3PRESET
 k
 S ^VCOMP=$Q(A)_$Q(A(""))_$Q(A("0"))_$Q(A("a"))
 S ^VCORR="" D ^VEXAMINE
 ;
58 S ^ABSN="30441",^ITEM="III-0441  gvn is undefined"
 S ^NEXT="59^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV
 S ^VCOMP=$Q(^VV)_$Q(^VV(""))_$Q(^VV("0"))_$Q(^VV("a"))
 S ^VCORR="" D ^VEXAMINE K ^VV
 ;
59 S ^ABSN="30442",^ITEM="III-0442  Value of $Q(lvn) is an empty string"
 S ^NEXT="60^V3Q6,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b")=""
 S ^VCOMP=$Q(A("a","b"))_$Q(A("a","c"))_$Q(A("a "))_$Q(A("b"))
 S ^VCORR="" D ^VEXAMINE
 ;
60 S ^ABSN="30443",^ITEM="III-0443  Value of $Q(gvn) is an empty string"
 S ^NEXT="61^V3Q6,V3FN2^VV3" D ^V3PRESET
 k  K ^VV s ^VV("a","b")=""
 S ^VCOMP=$Q(^VV("a","b"))_$Q(^VV("a","c"))_$Q(^VV("a "))_$Q(^VV("b"))
 S ^VCORR="" D ^VEXAMINE K ^VV
 ;
61 W !!,"glvn has indirection"
 ;
 S ^ABSN="30444",^ITEM="III-0444  lvn has indirection"
 S ^NEXT="62^V3Q6,V3FN2^VV3" D ^V3PRESET
 k  s A="",A("a","b","c")=""
 s A="A(@X1,@@X3)",X1="X2",X2="a",X3="X4",X4="X5",X5="b"
 s B="A"
 S ^VCOMP=$Q(@A)_" "_$Q(@@B)
 S ^VCORR="A(""a"",""b"",""c"") A(""a"",""b"",""c"")" D ^VEXAMINE
 ;
62 S ^ABSN="30445",^ITEM="III-0445  gvn has indirection"
 S ^NEXT="63^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV="",^VV("a","b","c")=""
 s A="^VV(@X1,@@X3)",X1="X2",X2="a",X3="X4",X4="X5",X5="b"
 s B="A"
 S ^VCOMP=$Q(@A)_" "_$Q(@@B)
 S ^VCORR="^VV(""a"",""b"",""c"") ^VV(""a"",""b"",""c"")" D ^VEXAMINE K ^VV
 ;
63 S ^ABSN="30446",^ITEM="III-0446  gvn has gnamind"
 S ^NEXT="64^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c")=""
 s A="^VV(""a"",""b"")"
 S ^VCOMP=$Q(@A@("a"))_" "_$Q(@A@(""))
 S ^VCORR="^VV(""a"",""b"",""c"") ^VV(""a"",""b"",""c"")" D ^VEXAMINE K ^VV
 ;
64 W !!,"gvn has naked reference"
 ;
 S ^ABSN="30447",^ITEM="III-0447  gvn has naked reference"
 S ^NEXT="65^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","a")="",^VV("a","b","a")="a",^VV("a","b","c")=""
 S ^VCOMP=$Q(^(^("a")))
 S ^VCORR="^VV(""a"",""b"",""c"")" D ^VEXAMINE K ^VV
 ;
65 W !!,"glvn has function"
 ;
 S ^ABSN="30448",^ITEM="III-0448  lvn has function"
 S ^NEXT="66^V3Q6,V3FN2^VV3" D ^V3PRESET
 k  s A("a","b","c")=""
 S ^VCOMP=$Q(A("a","b",$O(A("a","a"))))
 S ^VCORR="A(""a"",""b"",""c"")" D ^VEXAMINE
 ;
66 S ^ABSN="30449",^ITEM="III-0449  gvn has function"
 S ^NEXT="67^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a","b","c")=""
 S ^VCOMP=$Q(^VV("a","b",$O(^VV("a","a"))))
 S ^VCORR="^VV(""a"",""b"",""c"")" D ^VEXAMINE K ^VV
 ;
67 W !!,"Nesting of $Q function"
 ;
 S ^ABSN="30450",^ITEM="III-0450  Nested $Q(lvn)"
 S ^NEXT="68^V3Q6,V3FN2^VV3" D ^V3PRESET
 k  s A("a")="",A("a","b")="",A("a","c")="",A("b","c")="",A("c","d")=""
 S ^VCOMP=$Q(A($TR($P($P($Q(A("a")),",",2),")"),""""),$TR($P($P($Q(A("a","b")),",",2),")"),"""")))
 S ^VCORR="A(""c"",""d"")" D ^VEXAMINE
 ;
68 S ^ABSN="30451",^ITEM="III-0451  Nested $Q(gvn)"
 S ^NEXT="END^V3Q6,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("a")="",^VV("a","b")="",^VV("a","c")="",^VV("b","c")="",^VV("c","d")=""
 S ^VCOMP=$Q(^VV($tr($P($P($Q(^VV("a")),",",2),")"),""""),$tr($P($P($Q(^VV("a","b")),",",2),")"),"""")))
 S ^VCORR="^VV(""c"",""d"")" D ^VEXAMINE K ^VV
 ;
END W !!,"End of 43 --- V3Q6",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
