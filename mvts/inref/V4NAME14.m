V4NAME14 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"35---V4NAME14:  $NAME function  -4-"
 ;
1 S ^ABSN="40264",^ITEM="IV-264  lvn contains $NAME function"
 S ^NEXT="2^V4NAME14,V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S A="a",B="b"
 S ^VCOMP=$NA(@$NAME(A(A,B,1E1)))
 S ^VCORR="A(""a"",""b"",10)" D ^VEXAMINE
 ;
2 S ^ABSN="40265",^ITEM="IV-265  lvn contains extrinsic special variable"
 S ^NEXT="3^V4NAME14,V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$na(@$$NAME)
 S ^VCORR="X(""A"",""B"",""C"",-.0234)" D ^VEXAMINE
 ;
3 S ^ABSN="40266",^ITEM="IV-266  lvn contains extrinsic function"
 S ^NEXT="4^V4NAME14,V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S X="x",Y="y",A="A",C="C1",C1="c1",Z="ZZ"
 S ^VCOMP=$NA(@$$NAME^V4NAE(A,"B",.C))
 S ^VCORR="ZZ(""x"",""y"",""C11"")" D ^VEXAMINE
 ;
 ;
4 S ^ABSN="40267",^ITEM="IV-267  one subscript of a local variable has maximum length"
 S ^NEXT="5^V4NAME14,V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S A="#############################################################################################################################################################################################################################################"
 S ^VCOMP=$na(V(A))
 S V="V(""#############################################################################################################################################################################################################################################"")"
 S ^VCORR=V D ^VEXAMINE
 ;
5 S ^ABSN="40268",^ITEM="IV-268  a local variable has maximum total length"
 S ^NEXT="6^V4NAME14,V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$NA(V(A,A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,"ABCDEFG"))
 S V="V(""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,""ABCDEFG"")"
 S ^VCORR=V D ^VEXAMINE
 ;
6 S ^ABSN="40269",^ITEM="IV-269  minimum to maximum number of one subscript of a local variable"
 S ^NEXT="V4NAME15^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S ^VCOMP=$NA(A(-1E-25,-1E25,1E-25,1E25))
 S ^VCORR="A(-.0000000000000000000000001,-10000000000000000000000000,.0000000000000000000000001,10000000000000000000000000)" D ^VEXAMINE
 ;
END W !!,"End of 35 --- V4NAME14",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
NAME() S A="A",B="B",C="C"
 Q "X(A,B,C,-000.0234)"
 ;
