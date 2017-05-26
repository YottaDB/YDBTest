V1IDNM2	;NAME LEVEL INDIRECTION -2-;KO-TS,V1IDNM,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1IDNM2: TEST OF NAME LEVEL INDIRECTION -2-"
	W !!,"SET command",!
497	W !,"I-497  indirection of the left side lvn"
	S ITEM="I-497  ",VCOMP=""
	S A="B",@A=1 S VCOMP=VCOMP_B_A S VCORR="1B" D EXAMINER
	;
498	W !,"I-498  indirection of the right side lvn"
	S ITEM="I-498  ",VCOMP=""
	S A="C",B="D",CD=3,AB=@(A_B) S VCOMP=VCOMP_AB_CD S VCORR="33" D EXAMINER
	;
499	W !,"I-499  indirection of the left side gvn"
	S ITEM="I-499  ",VCOMP=""
	S ^V1A(100)="^V1B(2)",@^V1A(100)=100 S VCOMP=VCOMP_^V1B(2)_^V1A(100)
	S VCORR="100^V1B(2)" D EXAMINER
	;
500	W !,"I-500  indirection of the right side gvn"
	S ITEM="I-500  ",VCOMP=""
	S ^V1A(100)="^V1B(2)",^V1B(2)=300,^V1A(200)=@^V1A(100)
	S VCOMP=VCOMP_^V1A(200)_^V1B(2)_^V1A(100)
	S VCORR="300300^V1B(2)" D EXAMINER
	;
501	W !,"I-501  indirection of lvn subscript"
	S ITEM="I-501  ",VCOMP=""
	S B="B1",B1=2,C="C(D)",D=3,C(3)=4,A(10,20)=30
	S A(@B)=10,A(@B,@C)=20,A(1)=A(@B),A(3)=A(A(@B),A(@B,@C))
	S VCOMP=A(2)_A(2,4)_A(1)_A(3),VCORR="10201030" D EXAMINER
	;
502	W !,"I-502  indirection of gvn subscript"
	S ITEM="I-502  ",VCOMP=""
	S ^V1A(2)="^V1A(3)",^(3)=22,^(4)="^V1A(5)",^V1A(5)=55
	S A="@^V1A(2)",B="^V1A(C)",C=00002,^V1A(@A)=100,^V1A(@^(4))=200
	S VCOMP=VCOMP_^V1A(22)_^V1A(55),VCORR="100200" D EXAMINER
	;
503	W !,"I-503  value of indirection contains function"
	S ITEM="I-503  ",VCOMP=""
	S A="@$E(""ABCDEF"",3)",B="@$E(""ABCDEF"",4)",D=40
	S @A=@B S @$P("BS;BB;FF;IO",";",2)=50
	S VCOMP=VCOMP_C_BB,VCORR="4050" D EXAMINER
	;
504	W !,"I-504  value of indirection is gvn"
	S ITEM="I-504  ",VCOMP="" K ^V1A
	S A="^V1A(B)",B=2,C="^(2,D)",D=10,@A="ABC",@C=20,%Z="^V1A(1)",^V1A(1)="###",%Z=@%Z
	S VCOMP=VCOMP_^V1A(2)_^V1A(2,10)_%Z
	S VCORR="ABC20###" D EXAMINER
	;
505	W !,"I-505  value of indirection is lvn"
	S ITEM="I-505  ",VCOMP=""
	S A="A(A(1))",A(1)=2,A(2)="20:10:40",B="@A(AA)",AA=11,A(11)="D"
	S @B=@A+5+@A,@("AB"_(1+2))=" STOP"
	S VCOMP=VCOMP_D_AB3,VCORR="45 STOP" D EXAMINER
	;
506	W !,"I-506  value of indirection contains numeric literal"
	S ITEM="I-506  ",VCOMP=""
	S @("%"_0023.00)="%23",@($E("ABC",2)_(1.2E2))="B120"
	S VCOMP=%23_" "_B120,VCORR="%23 B120" D EXAMINER
	;
507	W !,"I-507  2 levels of indirection"
	S ITEM="I-507  ",VCOMP=""
	S A1="@B2",B2="C3(2)",A="B",B="C",C=4,@A1=@@A*2
	S VCOMP=VCOMP_C3(2)_" "_A_B_C,VCORR="8 BC4" D EXAMINER
	;
508	W !,"I-508  3 levels of indirection"
	S ITEM="I-508  ",VCOMP=""
	S A(1)="@A(2)",A(2)="@A(C)",A(3)="A(4)",A(4)="A(5)",C=3
	S B(1)="B(2)",B(2)="B(C)",B(3)="B(4)",B(4)="B(5)"
	S @A(1)=@@@B(1),@@@B(1)=@A(1)
	S VCOMP=VCOMP_A(4)_" "_B(4),VCORR="B(5) B(5)" D EXAMINER
	;
END	W !!,"END OF V1IDNM2",!
	S ROUTINE="V1IDNM2",TESTS=12,AUTO=12,VISUAL=0 D ^VREPORT
	K  K ^V1A,^V1B Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
