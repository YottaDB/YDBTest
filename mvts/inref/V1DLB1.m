V1DLB1 ;IW-YS-TS,V1DLB,MVTS V9.10;15/6/96;$DATA AFTER SETTING AND KILLING SUBSCRIPT LVN -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"110---V1DLB1: $DATA after SETting and KILLing subscript lvn -1-",!
220 W !,"I-220  $DATA of undefined node which has immediate descendants"
 S ^ABSN="11494",^ITEM="I-220  $DATA of undefined node which has immediate descendants",^NEXT="221^V1DLB1,V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX S XX(2,1)=210 D DATA K XX(2) D DATA
 S ^VCORR="10 0 10 1 0 0 0 ****210****/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
221 W !,"I-221  $DATA of undefined node which has descendants 2 levels below"
 S ^ABSN="11495",^ITEM="I-221  $DATA of undefined node which has descendants 2 levels below",^NEXT="222^V1DLB1,V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX S XX(2,1,1)=2110 D DATA K XX(2) D DATA
 S ^VCORR="10 0 10 10 1 0 0 *****2110***/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
222 W !,"I-222  $DATA of undefined node whose immediate descendants are killed"
 S ^ABSN="11496",^ITEM="I-222  $DATA of undefined node whose immediate descendants are killed",^NEXT="223^V1DLB1,V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(2,1)="DEF" D DATA K XX(2,1) D DATA
 S ^VCORR="10 0 10 1 0 0 0 ****DEF****/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
223 W !,"I-223  $DATA of undefined node whose descendants 2 levels below are killed"
 S ^ABSN="11497",^ITEM="I-223  $DATA of undefined node whose descendants 2 levels below are killed",^NEXT="224^V1DLB1,V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX S XX(2,1,1)=2110 D DATA K XX(2,1,1) D DATA
 S ^VCORR="10 0 10 10 1 0 0 *****2110***/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
224 W !,"I-224  $DATA of defined node which has immediate descendants"
 S ^ABSN="11498",^ITEM="I-224  $DATA of defined node which has immediate descendants",^NEXT="225^V1DLB1,V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(2)=2000,XX(2,1)="210QWE" D DATA K XX(2) D DATA
 S ^VCORR="10 0 11 1 0 0 0 ***2000*210QWE****/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
225 W !,"I-225  $DATA of defined node which has descendants 2 levels below"
 S ^ABSN="11499",^ITEM="I-225  $DATA of defined node which has descendants 2 levels below",^NEXT="V1DLB2^V1DLB,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(2)=200,XX(2,1,1)=21100 D DATA K XX(2) D DATA
 S ^VCORR="10 0 11 10 1 0 0 ***200**21100***/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
END W !!,"End of 110---V1DLB1",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
DATA S ^VCOMP=^VCOMP_$D(XX)_" "_$D(XX(1))_" "_$D(XX(2))_" "_$D(XX(2,1))_" "
 S ^VCOMP=^VCOMP_$D(XX(2,1,1))_" "_$D(XX(2,2))_" "_$D(XX(3))_" "
 S ^VCOMP=^VCOMP_"*" I $D(XX)#10=1 S ^VCOMP=^VCOMP_XX
 S ^VCOMP=^VCOMP_"*" I $D(XX(1))#10=1 S ^VCOMP=^VCOMP_XX(1)
 S ^VCOMP=^VCOMP_"*" I $D(XX(2))#10=1 S ^VCOMP=^VCOMP_XX(2)
 S ^VCOMP=^VCOMP_"*" I $D(XX(2,1))#10=1 S ^VCOMP=^VCOMP_XX(2,1)
 S ^VCOMP=^VCOMP_"*" I $D(XX(2,1,1))#10=1 S ^VCOMP=^VCOMP_XX(2,1,1)
 S ^VCOMP=^VCOMP_"*" I $D(XX(2,2))#10=1 S ^VCOMP=^VCOMP_XX(2,2)
 S ^VCOMP=^VCOMP_"*" I $D(XX(3))#10=1 S ^VCOMP=^VCOMP_XX(3)
 S ^VCOMP=^VCOMP_"*/" Q
