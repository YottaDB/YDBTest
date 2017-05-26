V1DGB2 ;IW-YS-TS,V1DGB,MVTS V9.10;15/6/96;$DATA AFTER SETTING AND KILLING SUBSCRIPT GVN -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"115---V1DGB2: $DATA after SETting and KILLing subscript gvn -2-",!
206 W !,"I-206  $DATA of defined node which has descendants 2 levels below"
 S ^ABSN="11525",^ITEM="I-206  $DATA of defined node which has descendants 2 levels below",^NEXT="207^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1 S ^V1=000
 S ^V1(1)=1,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=3 D DATA
 K ^V1(2) D DATA
 S ^VCORR="11 1 11 11 1 1 1 *0*1*2*21*211*22*3*/11 1 0 0 0 0 1 *0*1*****3*/" D ^VEXAMINE
 ;
207 W !,"I-207  $DATA of defined node whose immediate descendants are killed"
 S ^ABSN="11526",^ITEM="I-207  $DATA of defined node whose immediate descendants are killed",^NEXT="208^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1
 S ^V1(1)=1,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=300 D DATA
 K ^V1(2) D DATA
 S ^VCORR="10 1 11 11 1 1 1 **1*2*21*211*22*300*/10 1 0 0 0 0 1 **1*****300*/" D ^VEXAMINE
 ;
208 W !,"I-208  $DATA of defined node whose descendants 2 levels below are killed"
 S ^ABSN="11527",^ITEM="I-208  $DATA of defined node whose descendants 2 levels below are killed",^NEXT="209^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1
 S ^V1(1)=1,^V1(2)=2,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=3000 D DATA
 K ^V1(2,1,1) D DATA
 S ^VCORR="10 1 11 10 1 1 1 **1*2**211*22*3000*/10 1 11 0 0 1 1 **1*2***22*3000*/" D ^VEXAMINE
 ;
209 W !,"I-209  $DATA of defined node whose parent is killed"
 S ^ABSN="11528",^ITEM="I-209  $DATA of defined node whose parent is killed",^NEXT="210^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP=""
 S ^V1=0,^V1(1)="1 HAPPY",^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211.1,^V1(3)=3
 K ^V1 D DATA
 S ^VCORR="0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
210 W !,"I-210  $DATA of defined node whose neighboring node is killed"
 S ^ABSN="11529",^ITEM="I-210  $DATA of defined node whose neighboring node is killed",^NEXT="853^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1
 S ^V1="ROOT",^V1(2,1,1)=2110,^V1(3)=3000 D DATA
 K ^V1A(1,2,3,4),^V1ZZZ(9,9,9) K A,B,C,V1,^V10,^V11,^V1(0)
 K ^V1(2,1,1) D DATA K ^V1(3) D DATA
 S ^VCORR="11 0 10 10 1 0 1 *ROOT****2110**3000*/11 0 0 0 0 0 1 *ROOT******3000*/1 0 0 0 0 0 0 *ROOT*******/" D ^VEXAMINE
 ;
853 W !,"I-853  Transition of $DATA from 11 to 1 after KILLing the only descendent"
 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
8531 S ^ABSN="12153",^ITEM="I-853.1  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="8532^V1DGB2,V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1
 S ^V1(1)=1,^V1(2)=2,^V1(2,2)=22,^V1(3)=3000 D DATA
 K ^V1(2,2) D DATA
 S ^VCORR="10 1 11 0 0 1 1 **1*2***22*3000*/10 1 1 0 0 0 1 **1*2****3000*/" D ^VEXAMINE
 ;
8532 ;--(12/2/93 add. in V8.02 for ANSI 1990 Std. KILL command)
 S ^ABSN="12154",^ITEM="I-853.2  Transition of $DATA from 11 to 1 after KILLing the only descendent",^NEXT="V1NR^VV1" D ^V1PRESET
 S ^VCOMP="" K ^V1
 S ^V1(1)=1,^V1(2)=2,^V1(2,1,1)=211,^V1(3)=3000 D DATA
 K ^V1(2,1,1) D DATA
 S ^VCORR="10 1 11 10 1 0 1 **1*2**211**3000*/10 1 1 0 0 0 1 **1*2****3000*/" D ^VEXAMINE
 ;
END W !!,"End of 115---V1DGB2",!
 K  K ^V1,^V1A,^V1ZZZ,^V10,^V11 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
DATA S ^VCOMP=^VCOMP_$D(^V1)_" "_$D(^V1(1))_" "_$D(^V1(2))_" "_$D(^V1(2,1))_" "
 S ^VCOMP=^VCOMP_$D(^V1(2,1,1))_" "_$D(^V1(2,2))_" "_$D(^V1(3))_" "
 S ^VCOMP=^VCOMP_"*" I $D(^V1)#10=1 S ^VCOMP=^VCOMP_^V1
 S ^VCOMP=^VCOMP_"*" I $D(^V1(1))#10=1 S ^VCOMP=^VCOMP_^V1(1)
 S ^VCOMP=^VCOMP_"*" I $D(^V1(2))#10=1 S ^VCOMP=^VCOMP_^V1(2)
 S ^VCOMP=^VCOMP_"*" I $D(^V1(2,1))#10=1 S ^VCOMP=^VCOMP_^V1(2,1)
 S ^VCOMP=^VCOMP_"*" I $D(^V1(2,1,1))#10=1 S ^VCOMP=^VCOMP_^V1(2,1,1)
 S ^VCOMP=^VCOMP_"*" I $D(^V1(2,2))#10=1 S ^VCOMP=^VCOMP_^V1(2,2)
 S ^VCOMP=^VCOMP_"*" I $D(^V1(3))#10=1 S ^VCOMP=^VCOMP_^V1(3)
 S ^VCOMP=^VCOMP_"*/" Q
