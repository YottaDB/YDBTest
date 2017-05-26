V2VNIA ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;VARIABLE NAME INIDIRECTION -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"14---V2VNIA: Variable name indirection -1-",!
 W !,"@lnamind@(L expr)",!
120 S ^ABSN="20132",^ITEM="II-120  lnamind is a lvn",^NEXT="121^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="",X="A(1)",@X@(2)=1,@X@(2,3)=2,X="A",@X@(2)=X
 S X="A(1)",Y="A",VCOMP=VCOMP_@X@(2)_@X@(2,3)_@Y@(2)
 S VCOMP=VCOMP_A(1,2)_A(1,2,3)_A(2)
 S ^VCOMP=VCOMP,^VCORR="12A12A" D ^VEXAMINE
 ;
121 S ^ABSN="20133",^ITEM="II-121  lnamind is a string literal",^NEXT="122^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="",@"A(1)"@(2)=1,@"A(1)"@(2,3)=2,@"A"@(2)=3
 S VCOMP=@"A(1)"@(2)_@"A(1,2)"@(3)_@"A"@(2)
 S VCOMP=VCOMP_A(1,2)_A(1,2,3)_A(2)
 S ^VCOMP=VCOMP,^VCORR="123123" D ^VEXAMINE
 ;
122 S ^ABSN="20134",^ITEM="II-122  lnamind is a rexpratom",^NEXT="123^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="" S @("A"_"(1,2)")@(3,4)=4,@$C(65,40,49,44,50,44,51,41)@($C(53))=5
 S @$E("A(1,2,3)B(1,2,3)",1,8)@($E(5678,2))=6,@$P("A(1,2)^B(1,2)","^",1)@(3,7)=7
 S @($E("ABC")_$C(40,49,44,50)_",3)")@(8)=8 S X="A(1,2,3)" S VCOMP=VCOMP_@X@(4)_@X@(5)_@X@(6)_@X@(7)_@X@(8)
 S X="A(""A"")",@X@("B","C")="C" S @"A(""A"",""B"")"@($C($A("D")))=$C($A(@"A(""A"")"@("B","C"))+1)
 S X="A(""A"",""B"")" S VCOMP=VCOMP_@X@("C")_@X@("D")
 S ^VCOMP=VCOMP,^VCORR="45678CD" D ^VEXAMINE
 ;
123 W !!,"@gnamind@(L expr)",!
 S ^ABSN="20135",^ITEM="II-123  gnamind is a gvn",^NEXT="124^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S ^VCOMP="" S ^VV="^VV(1)",@^VV@(2)=2 S ^VCOMP=^VV(1,2),^VCORR=2 D ^VEXAMINE
 ;
124 S ^ABSN="20136",^ITEM="II-124  gnamind is a indirection",^NEXT="125^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S ^VCOMP="" S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
 S ^VV(1,3)="^VV(2,3)" S @@^VV@(3)=3,^VCOMP=^VV(2,3),^VCORR=3 D ^VEXAMINE
 ;
125 S ^ABSN="20137",^ITEM="II-125  gnamind is 2 levels indirection",^NEXT="126^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S ^VCOMP=""
 S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
 S ^VV(1,3)="^VV(2,3)",^VV(1,4)="^VV(""A"",""B"")",^VV("A","B")="^VV(3,4)"
 S @@@^VV@(4)=4,^VCOMP=^VV(3,4),^VCORR=4 D ^VEXAMINE
 ;
126 S ^ABSN="20138",^ITEM="II-126  Subscript is variable name indirection",^NEXT="127^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S ^VCOMP=""
 S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
 S ^VV(1,3)="^VV(2,3)",^VV(1,4)="^VV(""A"",""B"")",^VV("A","B")="^VV(3,4)"
 S @^VV(3)@(@^VV(2)@(4))=5,^VCOMP=^VV("A","B",4),^VCORR="5" D ^VEXAMINE
 ;
127 W !!,"@lnamind@(L expr)",!
 S ^ABSN="20139",^ITEM="II-127  Multi use variable name indirection",^NEXT="128^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="" S X="A",A(1,2)="B(3,4)",@@X@(1,2)@(5,6)=1
 S X="A",A(1,2)="B(1,2)",B(1,2)=5,@@X@(1,2)@(@A(1,2),6)=2
 S @@X@(1,2)@(@@X@(1,2)@(5,6)+4,7)=3
 S VCOMP=VCOMP_B(3,4,5,6)_B(1,2,5,6)_B(1,2,6,7)
 S ^VCOMP=VCOMP,^VCORR="123" D ^VEXAMINE
 ;
128 W !!,"@gnamind@(L expr)",!
 S ^ABSN="20140",^ITEM="II-128  Multi use variable name indirection",^NEXT="129^V2VNIA,V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="" K ^VV,^V,^V2
 S ^V2="^VV",^VV(1,2)="^VV(3,4)",@@^V2@(1,2)@(5,6)=1
 S ^VV(1,2)="^V(1,2)",^V(1,2)=5,@@^V2@(1,2)@(@^VV(1,2),6)=2
 S @@^V2@(1,2)@(@@^V2@(1,2)@(5,6)+4,7)=3
 S VCOMP=VCOMP_^VV(3,4,5,6)_^V(1,2,5,6)_^V(1,2,6,7)
 S ^VCOMP=VCOMP,^VCORR="123" D ^VEXAMINE
 ;
129 S ^ABSN="20141",^ITEM="II-129  Effect of naked indicator by variable name indirection",^NEXT="V2VNIB^VV2" W !,^ITEM D ^V2PRESET
 S VCOMP="" K ^V S A="^V(1)",@A@(1,2)=2 S VCOMP=^(2)_^V(1,1,2)
 S ^V(1)="^(5)",^(2)=1,^(5,1)="^(3)" S VCOMP=VCOMP_$D(^V(11))
 S @@^(1)@(^(2))=3 S VCOMP=VCOMP_^(3)_^V(5,3)
 S ^VCOMP=VCOMP,^VCORR="22033" D ^VEXAMINE
 ;
END W !!,"End of 14---V2VNIA",!
 K  K ^VV,^V,^V2 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
