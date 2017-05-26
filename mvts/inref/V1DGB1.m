V1DGB1 ;IW-YS-TS,V1DGB,MVTS V9.10;15/6/96;$DATA AFTER SETTING AND KILLING SUBSCRIPT GVN -1-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"114---V1DGB1: $DATA after SETting and KILLing subscript gvn -1-",!
823 W !,"I-823  KILLing undefined subscripted global variables"
 S ^ABSN="11519",^ITEM="I-823  KILLing undefined subscripted global variables",^NEXT="201^V1DGB1,V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" KILL ^V1 DO DATA K ^V1(2) D DATA
 S ^VCOMP=VCOMP,^VCORR="0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
201 W !,"I-201  $DATA of undefined node which has immediate descendants"
 S ^ABSN="11520",^ITEM="I-201  $DATA of undefined node which has immediate descendants",^NEXT="202^V1DGB1,V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(2,1)=200 D DATA K ^V1(2) D DATA
 S ^VCOMP=VCOMP,^VCORR="10 0 10 1 0 0 0 ****200****/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
202 W !,"I-202  $DATA of undefined node which has descendants 2 levels below"
 S ^ABSN="11521",^ITEM="I-202  $DATA of undefined node which has descendants 2 levels below",^NEXT="203^V1DGB1,V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(2,2)=220,^V1(3)=300,^V1(2,1,1)=211 D DATA K ^V1(2) D DATA
 S ^VCOMP=VCOMP,^VCORR="10 0 10 10 1 1 1 *****211*220*300*/10 0 0 0 0 0 1 *******300*/" D ^VEXAMINE
 ;
203 W !,"I-203  $DATA of undefined node whose immediate descendants are killed"
 S ^ABSN="11522",^ITEM="I-203  $DATA of undefined node whose immediate descendants are killed",^NEXT="204^V1DGB1,V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(2,1)=200 D DATA K ^V1(2,1) D DATA
 S ^VCOMP=VCOMP,^VCORR="10 0 10 1 0 0 0 ****200****/0 0 0 0 0 0 0 ********/" D ^VEXAMINE
 ;
204 W !,"I-204  $DATA of undefined node whose descendants 2 levels below are killed"
 S ^ABSN="11523",^ITEM="I-204  $DATA of undefined node whose descendants 2 levels below are killed",^NEXT="205^V1DGB1,V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(3)=300,^V1(2,1,1)=211 D DATA K ^V1(2,1,1) D DATA
 S ^VCOMP=VCOMP,^VCORR="10 0 10 10 1 0 1 *****211**300*/10 0 0 0 0 0 1 *******300*/" D ^VEXAMINE
 ;
205 W !,"I-205  $DATA of defined node which has immediate descendants"
 S ^ABSN="11524",^ITEM="I-205  $DATA of defined node which has immediate descendants",^NEXT="V1DGB2^V1DGB,V1NR^VV1" D ^V1PRESET
 S VCOMP="" K ^V1
 S ^V1(1)=100,^V1(2)=2,^V1(2,1)=21,^V1(2,1,1)=211,^V1(2,2)=22,^V1(3)=300 D DATA
 K ^V1(2) D DATA
 S ^VCOMP=VCOMP,^VCORR="10 1 11 11 1 1 1 **100*2*21*211*22*300*/10 1 0 0 0 0 1 **100*****300*/" D ^VEXAMINE
 ;
END W !!,"End of 114---V1DGB1",!
 K  K ^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
DATA S VCOMP=VCOMP_$D(^V1)_" "_$D(^V1(1))_" "_$D(^V1(2))_" "_$D(^V1(2,1))_" "
 S VCOMP=VCOMP_$D(^V1(2,1,1))_" "_$D(^V1(2,2))_" "_$D(^V1(3))_" "
 S VCOMP=VCOMP_"*" I $D(^V1)#10=1 S VCOMP=VCOMP_^V1
 S VCOMP=VCOMP_"*" I $D(^V1(1))#10=1 S VCOMP=VCOMP_^V1(1)
 S VCOMP=VCOMP_"*" I $D(^V1(2))#10=1 S VCOMP=VCOMP_^V1(2)
 S VCOMP=VCOMP_"*" I $D(^V1(2,1))#10=1 S VCOMP=VCOMP_^V1(2,1)
 S VCOMP=VCOMP_"*" I $D(^V1(2,1,1))#10=1 S VCOMP=VCOMP_^V1(2,1,1)
 S VCOMP=VCOMP_"*" I $D(^V1(2,2))#10=1 S VCOMP=VCOMP_^V1(2,2)
 S VCOMP=VCOMP_"*" I $D(^V1(3))#10=1 S VCOMP=VCOMP_^V1(3)
 S VCOMP=VCOMP_"*/" Q
