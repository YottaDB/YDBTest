V1NR2 ;IW-YS-TS,V1NR,MVTS V9.10;15/6/96;NAKED REFERENCE -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"117---V1NR2: Naked references on gvn -2-",!
651 W !,"I-651  Effect of KILLing global variables on naked indicator"
6511 S ^ABSN="11539",^ITEM="I-651.1  Killing defined global variable",^NEXT="6512^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 S VCOMP=""
 K ^V1A S ^V1A(1,1)=6 K ^V1A(1) S ^(3)="F" S VCOMP=VCOMP_^V1A(3)
 K ^V1A S ^V1A(1,1)=4 K ^(1) S ^(3)="D" S VCOMP=VCOMP_^V1A(1,3)
 S ^VCOMP=VCOMP,^VCORR="FD" D ^VEXAMINE
 ;
6512 S ^ABSN="11540",^ITEM="I-651.2  Killing undefined global variable",^NEXT="6513^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 S VCOMP=""
 K ^V1A S ^V1A(1,1)=7 K ^V1A(0) S ^(3)="G" S VCOMP=VCOMP_^V1A(3)
 K ^V1A S ^V1A(1,1)=5 K ^(0) S ^(3)="E" S VCOMP=VCOMP_^V1A(1,3)
 S ^VCOMP=VCOMP,^VCORR="GE" D ^VEXAMINE
 ;
6513 S ^ABSN="11541",^ITEM="I-651.3  2 globals using",^NEXT="652^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 K ^V1A,^V1B S ^V1A(1,1)=8,^V1B(1,3)="*" K ^V1A(1,2) S ^(3)="H"
 S VCOMP=^V1B(1,3)_^V1A(1,3)
 S ^VCOMP=VCOMP,^VCORR="*H" D ^VEXAMINE
 ;
652 W !,"I-652  Interpretation of naked reference"
 S ^ABSN="11542",^ITEM="I-652  Interpretation of naked reference",^NEXT="825^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 K ^V1A S ^V1A(1,1)=11,^V1A(1,2,3)=123,^V1A(1,2,2)=122,^V1A(1,2,3,2)=1232
 S ^V1A(1,2,3,122,1232)="GLOBAL"
 S VCOMP=$DATA(^V1A(1,1)) S ^(^(1),^(2,3))=^(^(2),^(3,2))
 S VCOMP=VCOMP_^V1A(1,2,3,122,11,123),^VCOMP=VCOMP,^VCORR="1GLOBAL" D ^VEXAMINE
 ;
825 W !,"I-825  Naked reference of undefined global node whose immediate ascendant exist"
 S ^ABSN="11543",^ITEM="I-825  Naked reference of undefined global node whose immediate ascendant exist",^NEXT="826^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 K ^V1C S ^V1C(2,2)=2200
 S VCOMP=$D(^V1C(2,2))_" "_$D(^(2,2))_" "_$DATA(^(2,2,2))_" "
 S ^(2)="22222" S VCOMP=VCOMP_$D(^(2))_" "_^V1C(2,2,2,2,2)_" "_$D(^V1C)
 S ^VCOMP=VCOMP,^VCORR="1 0 0 1 22222 10" D ^VEXAMINE
 ;
826 W !,"I-826  Naked reference of undefined global node whose immediate ascendant does not exist"
 S ^ABSN="11544",^ITEM="I-826.1  Immediate ascendant is unsubscripted variable",^NEXT="8262^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 K ^V1A,^V1A(1)
 S ^(1)=1000 S VCOMP=$D(^V1A)_" "_$D(^V1A(1))_" "_^V1A(1)_" "_$D(^V1A(1,2))
 S ^VCOMP=VCOMP,^VCORR="10 1 1000 0" D ^VEXAMINE
 ;
8262 S ^ABSN="11545",^ITEM="I-826.2  Immediate ascendant is 2-subscripts variable",^NEXT="8263^V1NR2,V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 K ^V1A,^V1A(1) S VCOMP=$D(^V1A(1,2)) S ^(2,3)=123
 S VCOMP=VCOMP_^V1A(1,2,3),^VCOMP=VCOMP,^VCORR="0123" D ^VEXAMINE
 ;
8263 S ^ABSN="11546",^ITEM="I-826.3  Another same level variable exist",^NEXT="V1NR3^V1NR,V1NX^VV1" D ^V1PRESET
 S VCOMP=""
 K ^V1A,^V1A(1,1) S ^V1A(1,1)="X",VCOMP=VCOMP_$D(^(1,3)),^(4)="3",VCOMP=VCOMP_^V1A(1,1,4)
 K ^V1A S ^V1A(1,1)=99,VCOMP=VCOMP_$D(^(1,3)) S ^(4)="4" S VCOMP=VCOMP_^V1A(1,1,4)
 S ^VCOMP=VCOMP,^VCORR="0304" D ^VEXAMINE
 ;
END W !!,"End of 117---V1NR2",!
 K ^V1A,^V1B,^V1C K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
