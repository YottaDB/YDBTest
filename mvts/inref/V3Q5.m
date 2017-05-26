V3Q5 ;IW-KO-YS-TS,V3QUERY,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 W !!,"42---V3Q5: $QUERY(glvn) -5-"
 W !!,"Numeric interpretation of subscirpts"
 ;
45 S ^ABSN="30428",^ITEM="III-0428  single subscirpt of lvn"
 S ^NEXT="46^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d LOCAL1^V3QE s A="A(-1E11)",(B1,B2,B3)=""
 ;f I=1:1:35 s A=$Q(@A) s B=B_A_" "
 f I=1:1:7 s A=$Q(@A) s B1=B1_A_" "
 f I=8:1:20 s A=$Q(@A) s B2=B2_A_" "
 f I=21:1:35 s A=$Q(@A) s B3=B3_A_" "
 S ^VCOMP=(B1=X1)_(B2=X2)_(B3=X3)
 S ^VCORR="111" D ^VEXAMINE
 ;
46 S ^ABSN="30429",^ITEM="III-0429  single subscript of gvn"
 S ^NEXT="47^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d GLOBAL1^V3QE s A="^VV(-1E11)",(B1,B2,B3)=""
 ;f I=1:1:35 s A=$q(@A) s B=B_A_" "
 f I=1:1:7 s A=$q(@A) s B1=B1_A_" "
 f I=8:1:20 s A=$q(@A) s B2=B2_A_" "
 f I=21:1:35 s A=$q(@A) s B3=B3_A_" "
 S ^VCOMP=(B1=X1)_(B2=X2)_(B3=X3)
 S ^VCORR="111" D ^VEXAMINE
 ;
47 S ^ABSN="30430",^ITEM="III-0430  plural subscirpts of lvn"
 S ^NEXT="48^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d LOCAL2^V3QE s A="A(-1E11)",B=""
 f I=1:1 s A=$Q(@A) q:A=""  s B=B_A_" "
 S ^VCOMP=B
 S ^VCORR=X D ^VEXAMINE
 ;
48 S ^ABSN="30431",^ITEM="III-0431  plural subscripts of gvn"
 S ^NEXT="49^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d GLOBAL2^V3QE s A="^VV(-1E11)",B=""
 f I=1:1 s A=$Q(@A) q:A=""  s B=B_A_" "
 S ^VCOMP=B
 S ^VCORR=X D ^VEXAMINE
 ;
49 W !!,"Subscript is one character (95 graphics including space)"
 ;
 S ^ABSN="30432",^ITEM="III-0432  lvn subscript is one character"
 S ^NEXT="50^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d LOCAL3^V3QE s A="A("""")",B=""
 f I=1:1 s A=$Q(@A) q:A=""  s B=B_$s(A["""""":$e(A,4,5),A["""":$e(A,4),1:$e(A,3))
 S ^VCOMP=B
 S ^VCORR=X D ^VEXAMINE
 ;
50 S ^ABSN="30433",^ITEM="III-0433  gvn subscript is one character"
 S ^NEXT="51^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 d GLOBAL3^V3QE s A="^VV("""")",B=""
 f I=1:1 s A=$Q(@A) q:A=""  s B=B_$s(A["""""":$e(A,6,7),A["""":$e(A,6),1:$e(A,5))
 S ^VCOMP=B
 S ^VCORR=X D ^VEXAMINE
 ;
51 W !!,"Subscript is 63 characters"
 ;
 S ^ABSN="30434",^ITEM="III-0434  lvn subscript is 63 characters"
 S ^NEXT="52^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz1234567","012345678901234567890123456789012345678901234567890123456789012")=""
 S ^VCOMP=$Q(A("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz1234567"))
 S ^VCORR="A(""abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz1234567"",""012345678901234567890123456789012345678901234567890123456789012"")" D ^VEXAMINE
 ;
52 S ^ABSN="30435",^ITEM="III-0435  gvn subscript is 63 characters"
 S ^NEXT="53^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s ^VV("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz123456","012345678901234567890123456789012345678901234567890123456789012")=""
 S ^VCOMP=$Q(^VV("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz123456"))
 S ^VCORR="^VV(""abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz123456"",""012345678901234567890123456789012345678901234567890123456789012"")" D ^VEXAMINE
 K ^VV
 ;
53 W !!,"Subscript has a quotation character"
 ;
 S ^ABSN="30436",^ITEM="III-0436  lvn subscript has a quotation character"
 S ^NEXT="54^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("""")="",A("""","""")=""
 S ^VCOMP=$Q(A(""""))
 S ^VCORR="A("""""""","""""""")" D ^VEXAMINE
 ;
54 S ^ABSN="30437",^ITEM="III-0437  gvn subscript has a quotation character"
 S ^NEXT="55^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("""")="",^VV("""","""")=""
 S ^VCOMP=$Q(^VV(""""))
 S ^VCORR="^VV("""""""","""""""")" D ^VEXAMINE K ^VV
 ;
55 W !!,"Subscript has plural quotation characters"
 ;
 S ^ABSN="30438",^ITEM="III-0438  lvn subscript has plural quotation characters"
 S ^NEXT="56^V3Q5,V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k  s A("""""""")="",A("""""""","""""a""""b""""c""""d""""e""""f""""g""""h""""")=""
 S ^VCOMP=$Q(A(""""""""))
 S ^VCORR="A("""""""""""""""",""""""""""a""""""""b""""""""c""""""""d""""""""e""""""""f""""""""g""""""""h"""""""""")" D ^VEXAMINE
 ;
56 S ^ABSN="30439",^ITEM="III-0439  gvn subscript has plural quotation characters"
 S ^NEXT="V3Q6^V3QUERY,V3FN2^VV3" D ^V3PRESET
 k ^VV s ^VV("""""""")="",^VV("""""""","""""a""""b""""c""""d""""e""""f""""g""""h""""")=""
 S ^VCOMP=$Q(^VV(""""""""))
 S ^VCORR="^VV("""""""""""""""",""""""""""a""""""""b""""""""c""""""""d""""""""e""""""""f""""""""g""""""""h"""""""""")" D ^VEXAMINE K ^VV
 ;
END W !!,"End of 42 --- V3Q5",!
 K  K ^VV Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
