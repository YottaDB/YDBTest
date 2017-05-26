V4GET28 ;IW-KO-YS-TS,V4GET2,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"30---V4GET28:  $GET function  -8-"
 ;
 W !,"expr contains a function"
 ;
1 S ^ABSN="40232",^ITEM="IV-232  expr contains $DATA function"
 S ^NEXT="2^V4GET28,V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S ^VV("A","B")="AB"
 S ^VCOMP=$G(^VV("A"),$D(^VV)_"/"_$D(^VV("A"))_"/"_$D(^VV("A","B")))
 S ^VCORR="10/10/1" D ^VEXAMINE K ^VV
 ;
2 S ^ABSN="40233",^ITEM="IV-233  expr contains $SELECT function"
 S ^NEXT="3^V4GET28,V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S B="10000"
 S ^VCOMP=$g(^VV,$S($D(A):B,1:B+1))
 S ^VCORR="10001" D ^VEXAMINE
 ;
3 S ^ABSN="40234",^ITEM="IV-234  expr contains $GET function"
 S ^NEXT="4^V4GET28,V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S ^VV="VV"
 S ^VCOMP=$Get(^VV($G(A,"A"),"B"),$GET(A,^VV))
 S ^VCORR="VV" D ^VEXAMINE K ^VV
 ;
4 S ^ABSN="40235",^ITEM="IV-235  expr contains extrinsic special variable"
 S ^NEXT="5^V4GET28,V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S ^VCOMP=$g(^VV($$GETDATA^V4GETE),$$GETDATA^V4GETE)
 S ^VCORR="##" D ^VEXAMINE
 ;
5 S ^ABSN="40236",^ITEM="IV-236  expr contains extrinsic function"
 S ^NEXT="6^V4GET28,V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S X="A",Y=123,Z="ZZ"
 S ^VCOMP=$get(^VV("A",$E("BAC"),$TR("xys","12xx","XYZ"),"DKDKRRJKR",12),$$^V4GETE(X,"#",.Z))
 S ^VCORR="Aa #b ZZc" D ^VEXAMINE
 ;
6 S ^ABSN="40237",^ITEM="IV-237  expr contains nested functions"
 S ^NEXT="V4GET29^V4GET2,V4NAME^VV4" D ^V4PRESET K  K ^VV
 S ^VV(1)="A/B/C/D/E/F"
 S ^VCOMP=$G(^VV,$P($g(^VV,^VV(1)),$g(^VV(8),"/"),$s($d(V):4,1:3),$L($g(^VV(1),"/"),"/")))
 S ^VCORR="C/D/E/F" D ^VEXAMINE
 ;
END W !!,"End of 30 --- V4GET28",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
