V3GET6 ;IW-KO-YS-TS,V3GET,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 W !!,"6---V3GET6: $GET function -6-"
 W !!,"Combined $GET function"
 ;
 W !!,"$GET(lvn)",!
 ;
1 S ^ABSN="30079",^ITEM="III-79  lvn is indirection"
 S ^NEXT="2^V3GET6,V3TR^VV3" D ^V3PRESET K
 S B(3)="A(1,3)",A(1,3,4,67)="NA(2,3)",NA(2,3)="NAME"
 S ^VCOMP=$G(@@B(3)@(4,67))
 S ^VCORR="NAME" D ^VEXAMINE
 ;
2 S ^ABSN="30080",^ITEM="III-80  lvn contains $GET function"
 S ^NEXT="3^V3GET6,V3TR^VV3" D ^V3PRESET K
 S A="B",B="sub",G("sub")="INDIRECTION"
 S ^VCOMP=$get(G($G(@A)))
 S ^VCORR="INDIRECTION" D ^VEXAMINE
 ;
3 S ^ABSN="30081",^ITEM="III-81  lvn contains functions"
 S ^NEXT="4^V3GET6,V3TR^VV3" D ^V3PRESET K
 S AM="PM",PM="TIME"
 S ^VCOMP=$G(@@$E("NAME",2,3))
 S ^VCORR="TIME" D ^VEXAMINE
 ;
4 S ^ABSN="30082",^ITEM="III-82  lvn contains naked refernce"
 S ^NEXT="5^V3GET6,V3TR^VV3" D ^V3PRESET K  K ^V3GET
 S ^V3GET(1,2,3)=23,^V3GET(1,3)=13,X(23)="L"
 S ^VCOMP=$G(X(^(2,3)))_" "_^(3)
 S ^VCORR="L 23" D ^VEXAMINE K ^V3GET
 ;
 W !!,"$GET(gvn)",!
 ;
5 S ^ABSN="30083",^ITEM="III-83  gvn is indirection"
 S ^NEXT="6^V3GET6,V3TR^VV3" D ^V3PRESET K ^V3GET
 S ^V3GET(9)="^V3GET(3,5)",^V3GET(3,5,"BOOK",1)="DATA"
 S ^VCOMP=$G(@^V3GET(9)@("BOOK",1))
 S ^VCORR="DATA" D ^VEXAMINE K ^V3GET
 ;
6 S ^ABSN="30084",^ITEM="III-84  gvn contains $GET function"
 S ^NEXT="7^V3GET6,V3TR^VV3" D ^V3PRESET K
 S ^V3A(4)=4,C="c",^V3A("c",3)="C3",^V3B0(4,"C3")="OK"
 S ^VCOMP=$get(^V3B0($G(^V3A(4)),$G(^V3A($G(C),3))))
 S ^VCORR="OK" D ^VEXAMINE K ^V3B0,^V3A
 ;
7 S ^ABSN="30085",^ITEM="III-85  gvn contains functions"
 S ^NEXT="8^V3GET6,V3TR^VV3" D ^V3PRESET K  K ^V3GET
 S Y=1,X=2,^V3GET(21)="GOOD"
 S ^VCOMP=$G(^V3GET($s(Y="":Y,1:X_Y)))
 S ^VCORR="GOOD" D ^VEXAMINE K ^V3GET
 ;
8 S ^ABSN="30086",^ITEM="III-86  gvn contains naked refernce"
 S ^NEXT="V3TR^VV3" D ^V3PRESET K  K ^V3GET
 S ^V3GET(23,3)="T"
 S ^V3GET(1,2,3)=23,^V3GET(1,2,4)=124,^V3GET(23,124)="A",^V3GET(1,3)=13
 S ^VCOMP=$G(^V3GET(^(2,3),^(4)))_" "_^(3)
 S ^VCORR="A T" D ^VEXAMINE K ^V3GET
 ;
END W !!,"End of 6 --- V3GET6",!
 K  K ^V3GET,^V3B0,^V3A Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
