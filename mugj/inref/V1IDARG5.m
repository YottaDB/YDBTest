V1IDARG5	;ARGUMENT LEVEL INDIRECTION -5-;KO-MM-YS-TS,V1IDARG,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDARG5: TEST OF ARGUMENT LEVEL INDIRECTION -5-"
XECUTE	W !!,"XECUTE command",!
453	W !,"I-453  indirection of xecuteargument"
	S ITEM="I-453  ",VCOMP=""
	S A="B",B="S VCOMP=1" XECUTE @A
	S G="""S VCOMP=VCOMP_2"",H",H="S VCOMP=VCOMP_3" X @G
	S VCORR="123" D EXAMINER
	;
454	W !,"I-454  indirection of xecuteargument list"
	S ITEM="I-454  ",VCOMP=""
	S A="B",B="S VCOMP=VCOMP+1",C="""SET VCOMP=VCOMP+10,VCOMP=VCOMP/100"""
	X @A,@C S VCORR=".11" D EXAMINER
	;
455	W !,"I-455  2 levels of xecuteargument indirection"
	S ITEM="I-455  ",VCOMP="",A="%",%="X @C(1),@C(1)",C(1)="C"
	S C="SET VCOMP=VCOMP_""1 "",%=0,C=""S VCOMP=VCOMP_""""! """"""" X @A
	S VCOMP=VCOMP_%,VCORR="1 ! 0" D EXAMINER
	;
456	W !,"I-456  3 levels of xecuteargument indirection"
	S ITEM="I-456  ",VCOMP=""
	S B(0)="B",B="X B(1),@B(22)",B(1)="S A=1,A(1,2)=12",B(22)="B(2)"
	S B(2)="X B(3),@B(44),B(5)",B(3)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))"
	S B(44)="B(4)",B(4)="K A(1) S:1 VCOMP=VCOMP_""/""",B(5)="S VCOMP=VCOMP_$D(A)_"" ""_$D(A(1))"
	X @B(0) S VCORR="11 10/1 0" D EXAMINER
	;
457	W !,"I-457  Value of indirection contains name level indirection"
	S ITEM="I-457  ",VCOMP=""
	S C="@D",D="@E",E="F",F="S VCOMP=457" X @C
	S VCORR="457" D EXAMINER
	;
458	W !,"I-458  Value of indirection contains operators"
	S ITEM="I-458  ",VCOMP="" K ^V1
	S B(2)=10,K=100,^V1(K)="""S (A""_$E(""QWER"",2,3)_"",B(1),B(2))=B(2)+10"""
	X @^V1(K) S VCOMP=AWE_B(1)_B(2)
	S VCORR="202020" D EXAMINER
	;
459	W !,"I-459  Value of indirection contains function"
	S ITEM="I-459  ",VCOMP="" K ^V1
	S ^V1(2)="$S(12>23:""S VCOMP=VCOMP_$L(2)"",90<91:""S VCOMP=VCOMP_$L(32)"")"
	XECUTE @^V1(2)
	S VCORR="2" D EXAMINER
	;
460	W !,"I-460  Value of indirection contains argument level indirection"
	S ITEM="I-460  ",VCOMP=""
	S A="VCOMP=$P(""SET/TEST/LET"",""/"",2),A(1)=100",Z="S @A",B="C",C=1,Z(1)="Z"
	X:@B @Z(1) S VCOMP=VCOMP_A(1)
	S VCORR="TEST100" D EXAMINER
	;
END	W !!,"END OF V1IDARG5",!
	S ROUTINE="V1IDARG5",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  K ^V1 Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
