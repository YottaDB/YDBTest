V4QUERY ;IW-KO-TS-YS,VV4,MVTS V9.10;15/6/96;$QUERY
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 ;
 W !!,"118---V4QUERY: Tests of $QUERY function"
 ;
 w !,"lvn"
1 S ^ABSN="40741",^ITEM="IV-741  The last subscript is an empty string"
 S ^NEXT="2^V4QUERY,V4PRIN^VV4" D ^V4PRESET K
 k  s A("a","b")="",A("b","c")=""
 S ^VCOMP=$q(A(""))_$q(A("a"))_$q(A("b"))_$q(A("a","b",""))_$q(A("b","d",""))
 S ^VCORR="A(""a"",""b"")A(""a"",""b"")A(""b"",""c"")A(""b"",""c"")" D ^VEXAMINE
 ;
 w !,"gvn"
2 S ^ABSN="40742",^ITEM="IV-742  The last subscript is an empty string"
 S ^NEXT="V4PRIN^VV4" D ^V4PRESET K
 K ^VV s ^VV("a","b")="",^VV("a","b","c")=""
 S ^VCOMP=$Q(^VV(""))_$Q(^VV("a",""))_$Q(^VV("a","c",""))_$Q(^VV("a","b",""))
 S ^VCORR="^VV(""a"",""b"")^VV(""a"",""b"")^VV(""a"",""b"",""c"")" D ^VEXAMINE
 K ^VV
 ;
END W !!,"End of 118 --- V4QUERY",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
