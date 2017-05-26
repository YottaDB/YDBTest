VV2VNIB	;VARIABLE NAME INIDIRECTION -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2VNIB: VARIABLE NAME INDIRECTION -2-",!
130	W !,"II-130  Variable name indirection in postcondition"
	S ITEM="II-130.1  local",VCOMP="" K A,B,C,D
	S B="C(K)",K=1,C(1,"A")=2
	S:@B@("A")=2 D(1)="" S:@B@("A")=3 D(2)=""
	S VCOMP=VCOMP_$D(D(1))_$D(D(2))
	S VCORR="10" D EXAMINER
	;
	S ITEM="II-130.2  global",VCOMP="" K ^VV
	S B="^VV",^VV("A")=2
	S:@B@("A")=2 ^VV(10)="" S:@B@("A")=3 ^VV(11)=""
	S VCOMP=VCOMP_$D(^VV(10))_$D(^VV(11))
	S VCORR="10" D EXAMINER
	;
	S ITEM="II-130.3  DO and GOTO command",VCOMP="" K ^VV
	S B="C(K)",C(1,2,3,4)=11,K=1,C(1,"A")=2,C(1)=3,I=4,C(1,9)="A"
	D:@B@("A")=2 EA:@B@(2,3,4)=11,EB:@B@(@B@(@B@(9)),@B,I)=11,EC:@B@(2,3,4)=10
	D:@B@("A")=3 EA:@B@(2,3,4)=11,EB:@B@(@B@(@B@(9)),@B,I)=11,EC:@B@(2,3,4)=10
	;
	S B="^VV",^VV(1,2,3,4)=11,^VV("A")=2,^VV=3,I=4,^VV(9)="A"
	D:@B@("A")=2 EA:@B@(1,2,3,4)=11,EB:@B@(1,@B@(@B@(9)),@B,I)=11,EC:@B@(1,2,3,4)=10
	D:@B@("A")=3 EA:@B@(1,2,3,4)=11,EB:@B@(1,@B@(@B@(9)),@B,I)=11,EC:@B@(1,2,3,4)=10
	G:@B@("A")=2 G130:@B@(1,2,3,4)=11 S VCOMP=VCOMP_" ERROR GOTO 1 "
	S VCOMP=VCOMP_" ERROR GOTO 2 "
	;
G130	S VCORR="ABAB" D EXAMINER
	;
131	W !,"II-131  Variable name indirection in expr to the right of the ="
	S ITEM="II-131  ",VCOMP="" K A,B,C
	S B="C(K)",C(1,2,3,4)=11,K=1,C(1,"A")=2,C(1)=3,I=4,C(1,9)="A"
	S:@B@(@B@(@B@(9)),@B,I)=11 @B@(1)=@B@(9),@B@(2)=@B@(@B@(9))
	S:@B@(@B@(@B@(9)),@B,I)=10 @B@(3)=@B@(9),@B@(4)=@B@(@B@(9)) ; (local)
	S VCOMP=VCOMP_"*"_$D(C(1,1))_"*"_$D(C(1,2))_"*"_$D(C(1,3))_"*"_$D(C(1,4))
	;
	K ^VV S B="^VV",^VV(1,2,3,4)=11,^VV("A")=2,^VV=3,I=4,^VV(9)="A"
	S:@B@(1,@B@(@B@(9)),@B,I)=11 @B@(1)=@B@(9),@B@(2)=@B@(@B@(9)) ; (global)
	S:@B@(1,@B@(@B@(9)),@B,I)=10 @B@(3)=@B@(9),@B@(4)=@B@(@B@(9))
	S VCOMP=VCOMP_"*"_$D(^VV(1))_"*"_$D(^VV(2))_"*"_$D(^VV(3))_"*"_$D(^VV(4))
	S VCORR="*1*11*0*0*11*1*0*0" D EXAMINER
	;
132	W !,"II-132  Value of indirection contains variable name indirection"
	S ITEM="II-132.1  interpretation of indirection",VCOMP="" K C,B,A
	S B="A(1)",C="@B@(1)" S A(1,1)=1 S VCOMP=VCOMP_@C
	S @C=2 S VCOMP=VCOMP_A(1,1)
	S A(1,1,1)=3 S VCOMP=VCOMP_@C@(1) S @C@(1)=4 S VCOMP=VCOMP_A(1,1,1)
	S B="A(2)",C="@B@(2)",D="@C",@D=5 S VCOMP=VCOMP_A(2,2)_@D
	S @D@(2)=6 S VCOMP=VCOMP_A(2,2,2)_@D@(2)
	S B="A(3)",C(3,3)="@B",D="C(3)",E="@@D@(3)",@E=7 S VCOMP=VCOMP_A(3)_@E
	S @E@(3)=8 S VCOMP=VCOMP_A(3,3)_@E@(3) S:@E@(3)=8 VCOMP=VCOMP_@E@(3)
	S VCORR="1234556677888" D EXAMINER
	;
	S ITEM="II-132.2  another interpretation of indirection",VCOMP=""
	S G="@G1",G1="Z",Z="B",H1="H(1)",H="@@H1@(@G)@(""-"")",H(1,"B")="I(1)",I(1,"-")="C"
	S A="D(1,2,3,4,5)",B="@A@(""A"")",C="@B",D="@A@(@G)",E="@A@(@H)",F="@E@(1)=@B+@B"
	S @C=1,@D=@B,@E=@B+1,@F
	S VCOMP=VCOMP_@C_@D_@E_@E@(1)
	S VCOMP=VCOMP_D(1,2,3,4,5,"A")_D(1,2,3,4,5,"B")_D(1,2,3,4,5,"C")_D(1,2,3,4,5,"C",1)
	S VCORR="11221122" D EXAMINER
	;
	S ITEM="II-132.3  value of name indirection contains variable name indirection",VCOMP=""
	S B="A(1)",A="@B@(1)",A(1,1)="@B@(2)",A(1,2)="@B@(3)",A(1,3)="@B@(4)",A(1,4)="#"
	S VCOMP=VCOMP_A_@A_@@A_@@@A_@@@@A,@@@@A="$",VCOMP=VCOMP_A_@A_@@A_@@@A_@@@@A
	S VCORR="@B@(1)@B@(2)@B@(3)@B@(4)#@B@(1)@B@(2)@B@(3)@B@(4)$" D EXAMINER
	;
END	W !!,"END OF VV2VNIB",!
	S ROUTINE="VV2VNIB",TESTS=7,AUTO=7,VISUAL=0 D ^VREPORT
	K  K ^VV Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
EA	S VCOMP=VCOMP_"A" Q
EB	S VCOMP=VCOMP_"B" Q
EC	S VCOMP=VCOMP_"C" Q
