V1DLB2 ;IW-YS-TS,V1DLB,MVTS V9.10;15/6/96;$DATA AFTER SETTING AND KILLING SUBSCRIPT LVN -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"111---V1DLB2: $DATA after SETting and KILLing subscript lvn -2-",!
226 W !,"I-226  $DATA of defined node whose immediate descendants are killed"
 S ^ABSN="11500",^ITEM="I-226  $DATA of defined node whose immediate descendants are killed",^NEXT="227^V1DLB2,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(2,1)=210 D DATA S XX(2)=200 D DATA K XX(2,1) D DATA
 S ^VCORR="10 0 10 1 0 0 0 ****210****/10 0 11 1 0 0 0 ***200*210****/10 0 1 0 0 0 0 ***200*****/" D ^VEXAMINE
 ;
227 W !,"I-227  $DATA of defined node whose descendants 2 levels below are killed"
 S ^ABSN="11501",^ITEM="I-227  $DATA of defined node whose descendants 2 levels below are killed",^NEXT="228^V1DLB2,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(2)=200 D DATA S XX(2,1,1)="#2110" D DATA K XX(2,1,1) D DATA
 S ^VCORR="10 0 1 0 0 0 0 ***200*****/10 0 11 10 1 0 0 ***200**#2110***/10 0 1 0 0 0 0 ***200*****/" D ^VEXAMINE
 ;
228 W !,"I-228  $DATA of defined node whose parent is killed"
 S ^ABSN="11502",^ITEM="I-228  $DATA of defined node whose parent is killed",^NEXT="229^V1DLB2,V1DLC^VV1" D ^V1PRESET
 K XX S XX=0,XX(1)=100,XX(3)=300,XX(2,1,1)="^211",^VCOMP=""
 D DATA K XX D DATA
 S ^VCORR="11 1 10 10 1 0 1 *0*100***^211**300*/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
229 W !,"I-229  $DATA of defined node whose neighboring node is killed"
 S ^ABSN="11503",^ITEM="I-229  $DATA of defined node whose neighboring node is killed",^NEXT="230^V1DLB2,V1DLC^VV1" D ^V1PRESET
 K  S XX="ROOT",XX(2,1,1)="211GGG",XX(3)="3000",^VCOMP="" D DATA
 K A,Y,XX(50),XX(0),XX(2,1,1,1)
 K XX(2,1,1) D DATA K XX(3) D DATA
 S ^VCORR="11 0 10 10 1 0 1 *ROOT****211GGG**3000*/11 0 0 0 0 0 1 *ROOT******3000*/1 0 0 0 0 0 0 *ROOT*******/" D ^VEXAMINE
 ;
230 W !,"I-230  KILLing undefined subscripted local variables"
 S ^ABSN="11504",^ITEM="I-230  KILLing undefined subscripted local variables",^NEXT="852^V1DLB2,V1DLC^VV1" D ^V1PRESET
 K  S XX="ROOT",XX(1)=10,XX(3)=30,XX(2,1,1)=2110,^VCOMP="" D DATA
 K XX(2) D DATA K XX(2) D DATA
 S ^VCORR="11 1 10 10 1 0 1 *ROOT*10***2110**30*/11 1 0 0 0 0 1 *ROOT*10*****30*/11 1 0 0 0 0 1 *ROOT*10*****30*/" D ^VEXAMINE
 ;
852 W !,"I-852  Transition of $DATA from 11 to 1 after KILLing the only descendent"
 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
8521 S ^ABSN="12151",^ITEM="I-852.1  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="8522^V1DLB2,V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(1)=1,XX(2)=2,XX(2,2)=22,XX(3)=3000 D DATA
 K XX(2,2) D DATA
 S ^VCORR="10 1 11 0 0 1 1 **1*2***22*3000*/10 1 1 0 0 0 1 **1*2****3000*/" D ^VEXAMINE
 ;
8522 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
 S ^ABSN="12152",^ITEM="I-852.2  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="V1DLC^VV1" D ^V1PRESET
 S ^VCOMP="" K XX
 S XX(1)=1,XX(2)=2,XX(2,1,1)=211,XX(3)=3000 D DATA
 K XX(2,1,1) D DATA
 S ^VCORR="10 1 11 10 1 0 1 **1*2**211**3000*/10 1 1 0 0 0 1 **1*2****3000*/" D ^VEXAMINE
 ;
END W !!,"End of 111---V1DLB2",!
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
