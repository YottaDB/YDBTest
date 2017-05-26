V1XECA1	;XECUTE COMMAND -1.1-;YS-TS,V1XECA,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1XECA1: TEST OF XECUTE COMMAND -1.1-",!
805	W !,"I-805  Single argument"
	S ITEM="I-805  ",VCOMP="" XECUTE "S VCOMP=1" S VCORR="1" D EXAMINER
	;
806	W !,"I-806  Argument list"
	S ITEM="I-806  ",VCOMP="" X "S A=2","SET VCOMP=A" S VCORR="2" D EXAMINER
	;
807	W !,"I-807  Interpretation of argument as expression"
	S ITEM="I-807.1  SET command",VCOMP="" K A
	S X="S A=3 S VCOMP=A+1" X X S VCORR="4" D EXAMINER
	;
	S ITEM="I-807.2  argument contains _ operator" K A S A(1)=9
	S X(1)="S A=4" X X(1)_",VCOMP=A_0" S VCORR="40" D EXAMINER
	;
808	W !,"I-808  Postconditional of arguments"
	S ITEM="I-808.1  tvexpr is true",VCOMP=""
	S P=1 X:P=1 "S VCOMP=""#""":P=0,"S P=2":P=1,"S VCOMP=""B""":P=2
	S VCORR="B" D EXAMINER
	;
	S ITEM="I-808.2  tvexpr is false",VCOMP=""
	S P=1 X:P=1 "S P=3":P=2,"S VCOMP=""C""":0,"S VCOMP=""%""":P=4,"S VCOMP=""D""":P=3 S VCORR="" D EXAMINER
	;
	S ITEM="I-808.3  tvexpr contains indirection",VCOMP=""
	S P=1,Q="P",R="S" S P=3 X:@Q=3 R_":P="_(10\3_" ")_"VCOMP=""FE""":@Q_Q="3P" S VCORR="FE" D EXAMINER
	;
809	W !,"I-809  Postconditional of command word"
	S ITEM="I-809.1  tvexpr is true",VCOMP=""
	S P=1 XECUTE:P=1 "S VCOMP=""A"""
	S VCORR="A" D EXAMINER
	;
	S ITEM="I-809.2  tvexpr is false",VCOMP=""
	S P=1 X:P=2 "S VCOMP=""*"""
	S VCORR="" D EXAMINER
	;
END	W !!,"END OF V1XECA1",!
	S ROUTINE="V1XECA1",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"  PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
A	S VCOMP=VCOMP_4 Q
B	S VCOMP=VCOMP_6 Q
C	S VCOMP=VCOMP_I Q
D	S VCOMP=VCOMP_I Q
E	S VCOMP=VCOMP_I
