V4NAME18 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"39---V4NAME18:  $NAME function  -8-"
 ;
1 S ^ABSN="40293",^ITEM="IV-293  gvn contains extrinsic special variable"
 S ^NEXT="2^V4NAME18,V4NAME21^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S V=1
 S ^VCOMP=$name(^V($$V18,$$V18^V4NAME18))
 S ^VCORR="^V(2,3)" D ^VEXAMINE
 ;
2 S ^ABSN="40294",^ITEM="IV-294  gvn contains extrinsic function"
 S ^NEXT="3^V4NAME18,V4NAME21^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S C="C",A="A"
 S ^VCOMP=$NAME(^V(A,C,$$V19(A,.C),A,C,$$V19(A,.C),A,C))
 S ^VCORR="^V(""A"",""C"",""A1 C1"",""A"",""C1"",""A1 C11"",""A"",""C11"")" D ^VEXAMINE
 ;
 ;
3 S ^ABSN="40295",^ITEM="IV-295  one subscript of a global variable has maximum length"
 S ^NEXT="4^V4NAME18,V4NAME21^V4NAME,V4QLEN^VV4" D ^V4PRESET K
 S A="" F I=1:1:237 S A=A_"#"
 S A="#############################################################################################################################################################################################################################################"
 S ^VCOMP=$na(^V(A))
 S V="^V(""#############################################################################################################################################################################################################################################"")"
 S ^VCORR=V D ^VEXAMINE
 ;
4 S ^ABSN="40296",^ITEM="IV-296  a global variable has maximum total length"
 S ^NEXT="5^V4NAME18,V4NAME21^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A="ABCDEFGHIJ",B=1234567890
 S ^VCOMP=$NA(^V(A,A,A,A,A,A,A,A,B,B,B,B,B,B,B,B,B,B,"ABCDEFG"))
 S V="^V(""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",""ABCDEFGHIJ"",1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,1234567890,""ABCDEFG"")"
 S ^VCORR=V D ^VEXAMINE
 ;
5 S ^ABSN="40297",^ITEM="IV-297  minimum to maximum number of one subscript of a global variable"
 S ^NEXT="V4NAME21^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$NA(^V(-1E-25,-1E25,1E-25,1E25))
 S ^VCORR="^V(-.0000000000000000000000001,-10000000000000000000000000,.0000000000000000000000001,10000000000000000000000000)" D ^VEXAMINE
 ;
END W !!,"End of 39 --- V4NAME18",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
V18() ;
 S V=V+1 Q V
V19(X,Y) ;
 S X=X_1
 S Y=Y_1
 Q X_" "_Y
