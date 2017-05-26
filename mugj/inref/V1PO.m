V1PO	;PARENTHESIS AND OPERATOR;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1PO: TEST PRECEDENCE OF OPERATORS AND EFFECTS OF PARENTHESIS",!
719	W !,"I-719  priority of unary operators"
	S ITEM="I-719  " S A='0+'0,B='(0+1),C=1+-+(--(-1++2)+'(1+0)),D=+-'0
	S VCOMP=A_" "_B_" "_C_" "_D,VCORR="2 0 0 -1" D EXAMINER
	;
720	W !,"I-720  priority of binary operators"
	S ITEM="I-720.1  * and +"
	S A=2*3+1,B=(2*3)+1,C=2*(3+1),D=1+2*3,E=(1+2)*3,F=1+(2*3)
	S VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,VCORR="7 7 8 9 9 7" D EXAMINER
	;
	S ITEM="I-720.2  \ and *"
	S A=3\2*4,B=(3\2)*4,C=3\(2*4),D=3*2\4,E=(3*2)\4,F=3*(2\4)
	S VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,VCORR="4 4 0 1 1 0" D EXAMINER
	;
	S ITEM="I-720.3  # and *"
	S A=3#2*4,B=(3#2)*4,C=3#(2*4),D=3*2#4,E=(3*2)#4,F=3*(2#4)
	S VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,VCORR="4 4 3 2 2 6" D EXAMINER
	;
	S ITEM="I-720.4  ' and ="
	S A='6=5,B=('6)=5,C='(6=5),D='0=2,E=('0)=2,F='(0=2),G='6=1,H=('6)=1,I='(6=1)
	S VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F_" "_G_" "_H_" "_I,VCORR="0 0 1 0 0 1 0 0 1" D EXAMINER
	;
	S ITEM="I-720.5  & and ="
	S A=2&5=5,B=(2&5)=5,C=2&(5=5),D=2&5=1,E=(2&5)=1,F=2&(5=1)
	S VCOMP=A_" "_B_" "_C_" "_D_" "_E_" "_F,VCORR="0 0 1 1 1 0" D EXAMINER
	;
	S ITEM="I-720.6  ! and ="
	S A=0!2=1,B=(0!2)=1,C=0!(2=1),VCOMP=A_" "_B_" "_C,VCORR="1 1 0" D EXAMINER
	;
721	W !,"I-721  priority of all operators"
	S ITEM="I-721  " S A=1+2*3-4\5#6>7<8=9&10!11]12[13
	S B=1]2[3!4&5=6<7>8#9\10-11*12+13,C=1'>2+3'<4*5'=6-7'&8\9'!10
	S VCOMP=A_" "_B_" "_C,VCORR="0 -119 0" D EXAMINER
	;
722	W !,"I-722  effect of parenthesis on interpretation sequence"
	S ITEM="I-722  " S A=4-((2-3)*(4-2)+(2-1))*2,B=(1+(10/2+1)>(3-1*2)*4)
	S VCOMP=A_" "_B,VCORR="10 4" D EXAMINER
	;
723	W !,"I-723  nesting of parenthesis"
	S ITEM="I-723  " S A=1+(2*(3+(4*5)))
	S B=1+(2*(3-(4#(5\(6>(7<(8=(9&(10!(11](12[13)))))))))))
	S C=1'>(2+(3'<(4*5)))'=(6-(7'&(8\9)'!0)),D=((((((((((((((1+1.1))))))))))))))
	S VCOMP=A_" "_B_" "_C_" "_D,VCORR="47 -1 1 2.1" D EXAMINER
	;
END	W !!,"END OF V1PO",!
	S ROUTINE="V1PO",TESTS=10,AUTO=10,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
