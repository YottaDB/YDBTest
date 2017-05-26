V1FORB	;FOR COMMNAD -2-;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1FORB: TEST OF FOR COMMAND -2-",!
	W !,"List of forparameter",!
355	W !,"I-355  forparameter is expr"
	S ITEM="I-355  " S VCOMP="" FOR I=1,3,4,5.5,7,-1,"ABC",-2.3,50E-1 SET VCOMP=VCOMP_I_" "
	S VCOMP=VCOMP_I S VCORR="1 3 4 5.5 7 -1 ABC -2.3 5 5" D EXAMINER
	;
356	W !,"I-356  forparameter is numexpr1:numexpr2"
	S ITEM="I-356  ",VCOMP="" F I=.1:-.02,1:2 S VCOMP=VCOMP_I_" " I I<0 Q
	S VCOMP=VCOMP_I S VCORR=".1 .08 .06 .04 .02 0 -.02 -.02" D EXAMINER
	;
357	W !,"I-357  forparameter is numexpr1:numexpr2:numexpr3"
	S ITEM="I-357  ",VCOMP="" F I=1.5:0.1:2.1,1:-0.3:-1 S VCOMP=VCOMP_I_" "
	S VCOMP=VCOMP_I,VCORR="1.5 1.6 1.7 1.8 1.9 2 2.1 1 .7 .4 .1 -.2 -.5 -.8 -.8" D EXAMINER
	;
358	W !,"I-358  forparameter is mixture of the three above"
	S ITEM="I-358  ",VCOMP="" F I=-10.1,3*I,"ABC",2:-0.5:1,"1E0",5:2.5 S VCOMP=VCOMP_I_" " I I>9 Q
	S VCOMP=VCOMP_I,VCORR="-10.1 -30.3 ABC 2 1.5 1 1E0 5 7.5 10 10" D EXAMINER
	;
	W !!,"FOR lvn=forparameter",!
359	W !,"I-359  Value of lvn in execution of FOR scope"
	S ITEM="I-359  ",VCOMP="" K X F I=-2:1:3 S X(I)=I_" ",VCOMP=VCOMP_X(I)
	S VCOMP=VCOMP_I,VCORR="-2 -1 0 1 2 3 3" D EXAMINER
	;
360	W !,"I-360  lvn has subscript"
	S ITEM="I-360.1  3 subscripts" K J(1,2,3) S VCOMP="" F J(1,2,3)=1:1:3 S VCOMP=VCOMP_J(1,2,3)_" "
	S VCOMP=VCOMP_J(1,2,3),VCORR="1 2 3 3" D EXAMINER
	;
	S ITEM="I-360.2  1 subscript",VCOMP="" S I=1,J(3)="A",J(5)="B",J(7)="C" F J(I)=1:1:3 S I=I+2,VCOMP=VCOMP_J(I)_" "
	S VCOMP=VCOMP_J(1),VCORR="A B C 3" D EXAMINER
	;
	S ITEM="I-360.3  subscript contains binary operator",VCOMP="",A=1,B=2,C=3,D=4,E=5
	F A(A+B+C,$A(A),D_E)=1:1:3 S A=A+1 S VCOMP=VCOMP_A_" "
	S VCOMP=VCOMP_A(6,49,45),VCORR="2 3 4 3" D EXAMINER
	;
361	W !,"I-361  Interpretation sequence of forparameter"
	S ITEM="I-361.1  forparameter is expr",VCOMP="" K I F I=$D(I),$D(I),$D(I) S VCOMP=VCOMP_$D(I)_" "_I_"  " I I=1 K I
	S VCOMP=VCOMP_I,VCORR="1 0  1 1  1 0  0" D EXAMINER
	;
	S ITEM="I-361.2  forparameter is numexpr1:numexpr2",VCOMP=""
	K I S K=0,I(1)="" F I=$D(I):$D(I) S K=K+1,VCOMP=VCOMP_I_" " S:I=40 I="ABCD" I K=8 Q
	S VCOMP=VCOMP_I,VCORR="10 20 30 40 10 20 30 40 ABCD" D EXAMINER
	;
	S ITEM="I-361.3  forparameter is numexpr1:numexpr2:numexpr3",VCOMP=""
	K I S K=0,I(1)="" F I=$D(I):$D(I):$D(I) S K=K+1,VCOMP=VCOMP_I_" "
	S VCOMP=VCOMP_I,VCORR="10 10" D EXAMINER
	;
	S ITEM="I-361.4  numexpr2 is lvn",VCOMP="",I=5,A(5)=13
	F I=1:A(I):100 S VCOMP=VCOMP_I_" "
	S VCOMP=VCOMP_I,VCORR="1 14 27 40 53 66 79 92 92" D EXAMINER
	;
362	W !,"I-362  forparameter contains lvn"
	S ITEM="I-362  ",VCOMP="",A=1,B=1 F I=A,B,B,C S B=B+1,C=4 S VCOMP=VCOMP_I_" "
	S VCOMP=VCOMP_I,VCORR="1 2 3 4 4" D EXAMINER
	;
363	W !,"I-363  Change the value of lvn in FOR scope"
	S ITEM="I-363.1  SET lvn=lvn+1",VCOMP="" F I=2:2:10 SET I=I+1 F J=I:3:10 S VCOMP=VCOMP_I_"*"_J_" "
	S VCOMP=VCOMP_I_"*"_J,VCORR="3*3 3*6 3*9 6*6 6*9 9*9 9*9" D EXAMINER
	;
	S ITEM="I-363.2  DO command in FOR scope",VCOMP="" F I=1:.1E+1:3.3 D D20
	S VCOMP=VCOMP_I,VCORR="1233" D EXAMINER
	;
END	W !!,"END OF V1FORB",!
	S ROUTINE="V1FORB",TESTS=15,AUTO=15,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
D20	S VCOMP=VCOMP_I QUIT
