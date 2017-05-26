V1SET	;SET COMMAND;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1SET: TEST OF SET COMMAND",!
781	W !,"I-781  expr is string literal"
	S ITEM="I-781.1  subscripted variables assigned with constant values"
	SET A(1)="012345",A(2)=6789,A(2,1)="ONE",A(2,2)="TWO",A(3,3)=-32767
	SET VCOMP=A(1)_A(2)_A(2,1)_A(2,2)_A(3,3)
	S VCORR="0123456789ONETWO-32767" D EXAMINER
	;
	S ITEM="I-781.2  variables' values reassigned to other variables"
	S A=A(2,2),A(2,2)=A(2,1),A(2,1)=A(2),A(2)=A(1),A(1)=A(3,3)
	S VCOMP=A_A(1)_A(2)_A(2,1)_A(2,2)
	S VCORR="TWO-327670123456789ONE" D EXAMINER
	;
782	W !,"I-782  expr is lvn"
	S ITEM="I-782  " K A,B,C,D,E,F,^V1,^V1A
	S A="ONE",B="TWO",C(1)="TRON",D(5,4,3)="543000"
	S E=A,E(100)=B,E(2,3,4)=C(1),F(4,5,6)=D(5,4,3),A=D(5,4,3),C(1)=E(2,3,4)_B
	S ^V1=A,^V1A(100,2)=E(2,3,4),^V1A(01,20)=D(5,4,3)*0.001
	S VCOMP=E_E(100)_E(2,3,4)_F(4,5,6)_A_C(1)_" "_^V1_^V1A(100,2)_^V1A(1,20)
	S VCORR="ONETWOTRON543000543000TRONTWO 543000TRON543" D EXAMINER
	;
783	W !,"I-783  expr is gvn"
	S ITEM="I-783  " K ^V1,^V1A,A,B,C,^V1B
	S ^V1="^V1",^V1A(02,20)="OS220",^V1A(100,101)=20,^V1B(30,2)="HOME",C=2
	S A=^V1A(2,20),^V1A=^V1B(30,C),B(123,C,1)=^V1A(2,20)_^V1A(C,^V1A(100,101))
	S ^V1B(9,9)=^V1B(30,2)_^V1A
	S VCOMP=A_" "_^V1A_" "_B(123,2,1)_" "_^V1_" "_^V1B(9,9)
	S VCORR="OS220 HOME OS220OS220 ^V1 HOMEHOME" D EXAMINER
	;
784	W !,"I-784  glvn is subscripted variable"
	S ITEM="I-784  " K A,B,^V1A,^V1B
	S A=1,B=2,B(3)=30
	S A(A)=10,A(A,B)=20,B(B(3),A(A))=30,B(A+B,A(A,B)+1)=40
	S VCOMP=A(1)_" "_A(1,2)_" "_B(30,10)_" "_B(3,21)_" "
	S ^V1B(A)=50,^V1A(B,B(3))=60,^V1A(^V1B(1),^V1A(B,B(3)),B(A+B,A(A,B)+1))=70
	S VCOMP=VCOMP_^V1B(1)_" "_^V1A(2,30)_" "_^V1A(50,60,40)
	S VCORR="10 20 30 40 50 60 70" D EXAMINER
	;
785	W !,"I-785  Multi-assigment of unsubscripted variables"
	S ITEM="I-785  ",VCOMP="" K A,B,C,D,E,F,^V1,^V1A
	S (A,B,C,D,E,F,^V1,^V1A)=1
	S VCOMP=A_B_C_D_E_F_^V1_^V1A
	S VCORR="11111111" D EXAMINER
	;
786	W !,"I-786  Multi-assigment of subscripted variables"
	S ITEM="I-786  ",VCOMP="" K Z,^V1,Y
	S (Z(1),Z(2,3),X,^V1(1),^V1(2,3),Y)="Z"
	S VCOMP=X_Y_Z(1)_Z(2,3)_^V1(1)_^V1(2,3)
	S (Q(A),B,^V1(1))=2
	S VCOMP=VCOMP_Q(A)_B_^V1(1)
	S VCORR="ZZZZZZ222" D EXAMINER
	;
787	W !,"I-787  Execution sequence of SET command"
	S ITEM="I-787  ",V=""
	S V=V_" " K ^V1A,^V1B S ^V1A(2)="A",^V1B(1)=^(2) S V=V_^V1A(2)_^V1B(1)
	S V=V_" " K ^V1A,^V1B S ^V1A(2)="B",^(1)=^V1A(2) S V=V_^V1A(2)_^V1A(1)
	S V=V_" " K ^V1A,^V1B S ^V1A(1,2)="C",^V1A(1)=0,^(1)=^(1,2) S V=V_^V1A(1)_^V1A(1,1)
	S V=V_" " K ^V1A,^V1B S ^V1A(1)=3,^V1A(2)="D",^V1B(^(1))=^(2) S V=V_^V1B(3)
	S V=V_" " K ^V1A,^V1B S ^V1A(2)="E",^V1B(1)=3,^(^(1))=^V1A(2) S V=V_^V1A(3)
	S V=V_" " K ^V1A,^V1B S ^V1A(1,2)=4,^(3)="F",^V1A(1)=5
	S ^V1B(^(1),^(1,2))=^(3) S V=V_^V1B(5,4)
	S V=V_" " K ^V1A,^V1B S ^V1B(2)=1,^V1B(3)="G",^V1A(1)=2
	S ^(^(1),^V1B(2))=^(3),^(5)="$" S V=V_^V1B(2,1)_^V1B(2,5)
	S V=V_" " K ^V1A,^V1B S ^V1B(2)=1,^V1B(2,3)="H",^V1B(2,1)=4,^V1A(1)=2
	S ^(^(^(1),^V1B(2)),1)=^(3),^(6)="%" S V=V_^V1B(2,4,1)_^V1B(2,4,6)
	S V=V_" " K A,B S A=1,B=2,(A,B,B(A,B))="I" S V=V_A_B_B(1,2)
	S V=V_" " K ^V1A,^V1B,^V1C,^V1D,^V1E S ^V1B(2)=2,^V1D(5)=5,^V1E(6,7)="J"
	S ^V1E(7)=7,^V1B(1,2)=8,^V1B(1,3)=3,^V1B(1,4)=4,^V1A(1)=1
	S (^(^(^(1),^V1B(2))),^V1C(^(3),4),^(^(4),^V1D(5)))=^(6,^V1E(7))
	S V=V_^V1E(6,8)_^V1C(3,4)_^V1C(3,4,5)
	S VCOMP=V,VCORR=" AA BB 0C D E F G$ H% III JJJ" D EXAMINER
	;
END	W !!,"END OF V1SET",!
	S ROUTINE="V1SET",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  K ^V1,^V1A,^V1B,^V1C,^V1D,^V1E Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
