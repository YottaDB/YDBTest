V1DLC ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;SELECTION AND EXCLUSIVE KILL OF SUBSCRIPTED LVN
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"112---V1DLC: Selection and exclusive KILL of subscripted lvn",!
231 W !,"I-231  Selective KILL"
 S ^ABSN="11505",^ITEM="I-231  Selective KILL",^NEXT="232^V1DLC,V1DGA^VV1" D ^V1PRESET
 K  S X(1,2)="X12",Y(3)="Y3",Z="Z",Z(0)="Z0",W="W",^VCOMP="" D DATA
 K Y D DATA S Y="Y" D DATA
 S ^VCORR="10 10 1 10 1 11 1 1 ***X12**Y3*Z*Z0*W*/10 10 1 0 0 11 1 1 ***X12***Z*Z0*W*/10 10 1 1 0 11 1 1 ***X12*Y**Z*Z0*W*/" D ^VEXAMINE
 ;
232 W !,"I-232  Exclusive KILL with argument list"
 S ^ABSN="11506",^ITEM="I-232  Exclusive KILL with argument list",^NEXT="233^V1DLC,V1DGA^VV1" D ^V1PRESET
 K  S X(1,2)="X12",Y(3)="Y3",Z="Z",Z(0)="Z0",W="W",^VCOMP="" D DATA
 K (X,Y,Z),(X,W) D DATA
 S ^VCORR="10 10 1 10 1 11 1 1 ***X12**Y3*Z*Z0*W*/10 10 1 0 0 0 0 0 ***X12******/" D ^VEXAMINE
 ;
233 W !,"I-233  Exclusive KILL with one argument"
 S ^ABSN="11507",^ITEM="I-233  Exclusive KILL with one argument",^NEXT="234^V1DLC,V1DGA^VV1" D ^V1PRESET
 K  S X(1,2)="X12",Y(3)="Y3",Z="Z",Z(0)="Z0",W="W",^VCOMP="" D DATA
 K (X,Y,Z) D DATA
 S ^VCORR="10 10 1 10 1 11 1 1 ***X12**Y3*Z*Z0*W*/10 10 1 10 1 11 1 0 ***X12**Y3*Z*Z0**/" D ^VEXAMINE
 ;
234 W !,"I-234  Exclusive KILL, which lvn is not defined"
 S ^ABSN="11508",^ITEM="I-234  Exclusive KILL, which lvn is not defined",^NEXT="235^V1DLC,V1DGA^VV1" D ^V1PRESET
 K  S X(1,2)="X12",Y(3)="Y3",Z="Z",Z(0)="Z0",W="W",^VCOMP="" D DATA
 K (A,B,C) D DATA
 S ^VCORR="10 10 1 10 1 11 1 1 ***X12**Y3*Z*Z0*W*/0 0 0 0 0 0 0 0 *********/" D ^VEXAMINE
 ;
235 W !,"I-235  Mixture of selective KILL and exclusive KILL in one argument"
 S ^ABSN="11509",^ITEM="I-235  Mixture of selective KILL and exclusive KILL in one argument",^NEXT="V1DGA^VV1" D ^V1PRESET
 K  S X(1,2)="X12",Y(3)="Y3",Z="Z",Z(0)="Z0",W="W",^VCOMP="" D DATA
 K (X,W),Z D DATA
 S ^VCORR="10 10 1 10 1 11 1 1 ***X12**Y3*Z*Z0*W*/10 10 1 0 0 0 0 1 ***X12*****W*/" D ^VEXAMINE
 ;
END W !!,"End of 112---V1DLC",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
DATA S ^VCOMP=^VCOMP_$D(X)_" "_$D(X(1))_" "_$D(X(1,2))_" "_$D(Y)_" "
 S ^VCOMP=^VCOMP_$D(Y(3))_" "_$D(Z)_" "_$D(Z(0))_" "_$D(W)_" "
 S ^VCOMP=^VCOMP_"*" I $D(X)#10=1 S ^VCOMP=^VCOMP_X
 S ^VCOMP=^VCOMP_"*" I $D(X(1))#10=1 S ^VCOMP=^VCOMP_X(1)
 S ^VCOMP=^VCOMP_"*" I $D(X(1,2))#10=1 S ^VCOMP=^VCOMP_X(1,2)
 S ^VCOMP=^VCOMP_"*" I $D(Y)#10=1 S ^VCOMP=^VCOMP_Y
 S ^VCOMP=^VCOMP_"*" I $D(Y(3))#10=1 S ^VCOMP=^VCOMP_Y(3)
 S ^VCOMP=^VCOMP_"*" I $D(Z)#10=1 S ^VCOMP=^VCOMP_Z
 S ^VCOMP=^VCOMP_"*" I $D(Z(0))#10=1 S ^VCOMP=^VCOMP_Z(0)
 S ^VCOMP=^VCOMP_"*" I $D(W)#10=1 S ^VCOMP=^VCOMP_W
 S ^VCOMP=^VCOMP_"*/" Q
