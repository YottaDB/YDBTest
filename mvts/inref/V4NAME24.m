V4NAME24 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"43---V4NAME24:  $NAME function  -12-"
 ;
1 S ^ABSN="40319",^ITEM="IV-319  subscript is naked reference"
 S ^NEXT="2^V4NAME24,V4NAME25^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V(2,3)="b",^V("2",3,4,5)="c",^V("2",3,4,6)="d",^V("2",3,4,7)="ABCDEFGHIJKL"
 S ^V(1)="a"
 S ^VCOMP=$na(^(^(1),^(2,3),^(3,4,5),^(6)),$L(^(7)))
 S ^VCORR="^V(2,3,4,""a"",""b"",""c"",""d"")" D ^VEXAMINE K ^V
 ;
 W !,"$QL(gvn)'>intexpr"
 ;
2 S ^ABSN="40320",^ITEM="IV-320  1 subscript"
 S ^NEXT="3^V4NAME24,V4NAME25^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$na(^V("1234567"),1)
 S ^VCORR="^V(1234567)" D ^VEXAMINE K ^V
 ;
3 S ^ABSN="40321",^ITEM="IV-321  2 subscripts"
 S ^NEXT="4^V4NAME24,V4NAME25^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$na(^V("A,B","C,D"),3)
 S ^VCORR="^V(""A,B"",""C,D"")" D ^VEXAMINE K ^V
 ;
4 S ^ABSN="40322",^ITEM="IV-322  5 subscripts"
 S ^NEXT="5^V4NAME24,V4NAME25^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A=$C(34),B=A_A,C=B_A,D=C_A,E=D_A
 S ^VCOMP=$na(^V(A,B,C,D,E),99999999)
 S ^VCORR="^V("""""""","""""""""""","""""""""""""""","""""""""""""""""""","""""""""""""""""""""""")" D ^VEXAMINE K ^V
 ;
5 S ^ABSN="40323",^ITEM="IV-323  subscript is naked reference"
 S ^NEXT="V4NAME25^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
; **MVTS LOCAL CHANGE**
; ** Original version: S ^V(1,1,2)="1E12"
; Cause overflow when converting to int for op_fnname resulting
; in negative number which op_fnname didn't like.
 S ^V(1,1,2)="1E8"
 S ^V(1,2)="-1E12"
 S A=$D(^V(1))
 S ^VCOMP=$na(^V(+^(1,2)),^(1,2))
 S ^VCORR="^V(-1000000000000)" D ^VEXAMINE
 ;
END W !!,"End of 43 --- V4NAME24",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
