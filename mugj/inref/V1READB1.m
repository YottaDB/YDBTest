V1READB1	;READ AND $TEST AND READ LEVEL INDIRECTION -1-;KO-TS,V1READB,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1READB1: TEST READ AND $TEST AND READ LEVEL INDIRECTION -1-",!
	W !,"READ WITH TIMEOUT",!
	;
760	W !,"I-760/761/762  timeout is equal to 0 or less than 0"
	W !,"   NEVER TOUCH ANY KEY WITHOUT INSTRUCTION" K A
	S ITEM="I-760/761/762.1  READ lvn timeout and timeout is equal to 0",VCOMP="" I 1
	R !!,"   R A:0",A:0 S VCOMP=$D(A)_" "_$T_" "_A_" "_(A="") S VCORR="1 0  1" D EXAMINER
	;
	S ITEM="I-760/761/762.2  READ *lvn timeout and timeout is equal to 0",VCOMP="" I 1 K A
	READ !!,"   READ *A:0",*A:0
	S VCOMP=$D(A)_" "_$T_" "_A_" "_(A=-1) S VCORR="1 0 -1 1" D EXAMINER
	;
	S ITEM="I-760/761/762.3  READ lvn timeout and timeout is less than 0",VCOMP="" I 1 K A
	R !!,"   R A:-1",A:-1
	S VCOMP=$D(A)_" "_$T_" "_A_" "_(A="") S VCORR="1 0  1" D EXAMINER
	;
	S ITEM="I-760/761/762.4  READ *lvn timeout and timeout is less than 0",VCOMP="" I 1 K A
	R !!,"   R *A:-1",*A:-1 S VCOMP=$D(A)_" "_$T_" "_A_" "_(A=-1) S VCORR="1 0 -1 1" D EXAMINER
	;
763	W !!,"I-763/764  Value of $TEST and lvn, when input is terminated"
	S ITEM="I-763/764.1  READ lvn timeout",VCOMP="" K A
	R !!,"   R A:100  ; INPUT 'AB' <CR> WITHIN 100 SECONDS > ",A:100
	S VCOMP=$D(A)_" "_$TEST_" "_A_" "_(A="AB"),VCORR="1 1 AB 1" D EXAMINER
	;
	S ITEM="I-763/764.2  READ *lvn timeout",VCOMP="" K A I 0
	R !!,"   R *A:100  ; STRIKE 'A' KEY WITHIN 100 SECONDS > ",*A:100
	S VCOMP=$D(A)_" "_$T_" "_A_" "_(A=65),VCORR="1 1 65 1" D EXAMINER
	;
765	W !!,"I-765/766  Value of $TEST and lvn, when input is not terminated"
	S ITEM="I-765/766.1  READ lvn timeout",VCOMP="" K A I 1
	R !!,"   R A:10  ; STRIKE 'AB' AND NEVER TOUCH ENTRY KEY > ",A:10
	S VCOMP=$D(A)_" "_$T_" "_A_" "_(A="AB") S VCORR="1 0 AB 1" D EXAMINER
	;
	S ITEM="I-765/766.2  empty string",VCOMP="" K %A I 0
	R !!,"   R %A:10  ; STRIKE ONLY ENTRY KEY > ",%A:10
	S VCOMP=$D(%A)_" "_$T_" "_%A_" "_(%A="") S VCORR="1 1  1" D EXAMINER
	;
END	W !!,"END OF V1READB1",!
	S ROUTINE="V1READB1",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
