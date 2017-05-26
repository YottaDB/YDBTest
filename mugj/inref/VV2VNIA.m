VV2VNIA	;VARIABLE NAME INIDIRECTION -1-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2VNIA: VARIABLE NAME INDIRECTION -1-",!
	W !,"@lnamind@(L expr)",!
120	W !,"II-120  lnamind is lvn"
	S ITEM="II-120  ",VCOMP=""
	S X="A(1)",@X@(2)=1,@X@(2,3)=2,X="A",@X@(2)=X
	S X="A(1)",Y="A",VCOMP=VCOMP_@X@(2)_@X@(2,3)_@Y@(2)
	S VCOMP=VCOMP_A(1,2)_A(1,2,3)_A(2),VCORR="12A12A" D EXAMINER
	;
121	W !,"II-121  lnamind is string literal"
	S ITEM="II-121  ",VCOMP=""
	S @"A(1)"@(2)=1,@"A(1)"@(2,3)=2,@"A"@(2)=3
	S VCOMP=@"A(1)"@(2)_@"A(1,2)"@(3)_@"A"@(2)
	S VCOMP=VCOMP_A(1,2)_A(1,2,3)_A(2),VCORR="123123" D EXAMINER
	;
122	W !,"II-122  lnamind is rexpratom"
	S ITEM="II-122  ",VCOMP="" S @("A"_"(1,2)")@(3,4)=4,@$C(65,40,49,44,50,44,51,41)@($C(53))=5
	S @$E("A(1,2,3)B(1,2,3)",1,8)@($E(5678,2))=6,@$P("A(1,2)^B(1,2)","^",1)@(3,7)=7
	S @($E("ABC")_$C(40,49,44,50)_",3)")@(8)=8 S X="A(1,2,3)" S VCOMP=VCOMP_@X@(4)_@X@(5)_@X@(6)_@X@(7)_@X@(8)
	S X="A(""A"")",@X@("B","C")="C" S @"A(""A"",""B"")"@($C($A("D")))=$C($A(@"A(""A"")"@("B","C"))+1)
	S X="A(""A"",""B"")" S VCOMP=VCOMP_@X@("C")_@X@("D") S VCORR="45678CD" D EXAMINER
	;
	W !!,"@gnamind@(L expr)",!
123	W !,"II-123  gnamind is gvn"
	S ITEM="II-123  ",VCOMP=""
	S ^VV="^VV(1)",@^VV@(2)=2 S VCOMP=^VV(1,2),VCORR=2 D EXAMINER
	;
124	W !,"II-124  gnamind is indirection"
	S ITEM="II-124  ",VCOMP=""
	S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
	S ^VV(1,3)="^VV(2,3)" S @@^VV@(3)=3,VCOMP=^VV(2,3),VCORR=3 D EXAMINER
	;
125	W !,"II-125  gnamind is 2 levels indirection"
	S ITEM="II-125  ",VCOMP=""
	S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
	S ^VV(1,3)="^VV(2,3)",^VV(1,4)="^VV(""A"",""B"")",^VV("A","B")="^VV(3,4)"
	S @@@^VV@(4)=4,VCOMP=^VV(3,4),VCORR=4 D EXAMINER
	;
126	W !,"II-126  Subscript is variable name indirection"
	S ITEM="II-126  ",VCOMP=""
	S ^VV="^VV(1)",^VV(1)="^VV(2)",^VV(2)="^VV(3)",^VV(3)="^VV(""A"",""B"")"
	S ^VV(1,3)="^VV(2,3)",^VV(1,4)="^VV(""A"",""B"")",^VV("A","B")="^VV(3,4)"
	S @^VV(3)@(@^VV(2)@(4))=5,VCOMP=^VV("A","B",4),VCORR="5" D EXAMINER
	;
	W !!,"@lnamind@(L expr)",!
127	W !,"II-127  Multi use variable name indirection"
	S ITEM="II-127  ",VCOMP="" S X="A",A(1,2)="B(3,4)",@@X@(1,2)@(5,6)=1
	S X="A",A(1,2)="B(1,2)",B(1,2)=5,@@X@(1,2)@(@A(1,2),6)=2
	S @@X@(1,2)@(@@X@(1,2)@(5,6)+4,7)=3
	S VCOMP=VCOMP_B(3,4,5,6)_B(1,2,5,6)_B(1,2,6,7) S VCORR="123" D EXAMINER
	;
	W !!,"@gnamind@(L expr)",!
128	W !,"II-128  Multi use variable name indirection"
	S ITEM="II-128  ",VCOMP="" K ^VV,^V,^V2
	S ^V2="^VV",^VV(1,2)="^VV(3,4)",@@^V2@(1,2)@(5,6)=1
	S ^VV(1,2)="^V(1,2)",^V(1,2)=5,@@^V2@(1,2)@(@^VV(1,2),6)=2
	S @@^V2@(1,2)@(@@^V2@(1,2)@(5,6)+4,7)=3
	S VCOMP=VCOMP_^VV(3,4,5,6)_^V(1,2,5,6)_^V(1,2,6,7) S VCORR="123" D EXAMINER
	;
129	W !,"II-129  Effect of naked indicator by variable name indirection"
	S ITEM="II-129  ",VCOMP="" K ^V S A="^V(1)",@A@(1,2)=2 S VCOMP=^(2)_^V(1,1,2)
	S ^V(1)="^(5)",^(2)=1,^(5,1)="^(3)" S VCOMP=VCOMP_$D(^V(11))
	S @@^(1)@(^(2))=3 S VCOMP=VCOMP_^(3)_^V(5,3) S VCORR="22033" D EXAMINER
	;
END	W !!,"END OF VV2VNIA",!
	S ROUTINE="VV2VNIA",TESTS=10,AUTO=10,VISUAL=0 D ^VREPORT
	K  K ^VV,^V,^V2 Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
