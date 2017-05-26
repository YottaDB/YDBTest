V1DLA	;$DATA, KILL (LOCAL VARIABLES) -1-;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S ^PASS=0,^FAIL=0
	W !!,"V1DLA : TEST OF $DATA FUNCTION AND KILL COMMAND ON LOCAL VARIABLES -1-",!
824	W !,"I-824  KILLing undefined unsubscripted local variables"
	S ^ITEM="I-824  " K  S VCOMP="" D DATA S ^VCOMP=VCOMP
	K A K A,B,C S VCOMP=^VCOMP D DATA
	S VCORR="0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
211	W !,"I-211/212  SETting unsubscripted local variable and its $DATA value"
	S ^ITEM="I-211/212  " K
	S A=1,F="F" S VCOMP="" D DATA
	S VCORR="1 0 0 0 0 1 0 *1*****F**/" D EXAMINER
	;
213	W !,"I-213/214  KILLing unsubscripted local variable and its $DATA value"
	S ^ITEM="I-213/214  " K
	S A=100,G="GGG" S VCOMP="" D DATA K A,B,C,D,E,F,G,H,I,J,K D DATA
	S VCORR="1 0 0 0 0 0 1 *100******GGG*/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
215	W !,"I-215  Assign string literal to unsubscripted local variables"
	S ^ITEM="I-215  " K
	S A="ABC",D="DDD",C="C" S VCOMP="" D DATA K A,B,C D DATA
	S VCORR="1 0 1 1 0 0 0 *ABC**C*DDD****/0 0 0 1 0 0 0 ****DDD****/" D EXAMINER
	;
216	W !,"I-216  Assign numeric literal to unsubscripted local variables"
	S ^ITEM="I-216  " K
	S C=333,D=0020.030,G=0.020,VCOMP="" D DATA K D,G,A D DATA
	S VCORR="0 0 1 1 0 0 1 ***333*20.03***.02*/0 0 1 0 0 0 0 ***333*****/" D EXAMINER
	;
217	W !,"I-217  KILL all local variable"
	S ^ITEM="I-217  " K
	S B=2,C="CCC",A=1,E=5,F="FFF",D="DDD",VCOMP="" D DATA S ^VCOMP=VCOMP
	K  S VCOMP=^VCOMP D DATA
	S VCORR="1 1 1 1 1 1 0 *1*2*CCC*DDD*5*FFF**/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
218	W !,"I-218  Exclusive KILL"
	S ^ITEM="I-218  " K
	S B=2,C="CCC",A=1,E=5,F="FFF" S VCOMP="" D DATA S ^VCOMP=VCOMP
	K (E,F,G) S VCOMP=^VCOMP D DATA
	S VCORR="1 1 1 0 1 1 0 *1*2*CCC**5*FFF**/0 0 0 0 1 1 0 *****5*FFF**/" D EXAMINER
	;
219	W !,"I-219  Allowed local variable name"
	S ^ITEM="I-219  " K
	S %1234567=" %1234567 ",ABC123DE=" ABC123DE "
	S VCOMP=$D(%1234567)_%1234567_$D(ABC123DE)_ABC123DE
	S VCORR="1 %1234567 1 ABC123DE " D EXAMINER
	;
END	W !!,"END OF V1DLA",!
	S PASS=^PASS,FAIL=^FAIL
	S ROUTINE="V1DLA",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  K ^ITEM,^PASS,^FAIL,^VCOMP Q
	;
EXAMINER	I VCORR=VCOMP S PASS=^PASS,PASS=PASS+1,^PASS=PASS W !,"   PASS  ",^ITEM W:$Y>55 # Q
	S FAIL=^FAIL,FAIL=FAIL+1,^FAIL=FAIL W !,"** FAIL  ",^ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
DATA	S VCOMP=VCOMP_$D(A)_" "_$D(B)_" "_$D(C)_" "_$D(D)_" "_$D(E)_" "_$D(F)_" "_$D(G)_" "
	S VCOMP=VCOMP_"*" I $D(A)#10=1 S VCOMP=VCOMP_A
	S VCOMP=VCOMP_"*" I $D(B)#10=1 S VCOMP=VCOMP_B
	S VCOMP=VCOMP_"*" I $D(C)#10=1 S VCOMP=VCOMP_C
	S VCOMP=VCOMP_"*" I $D(D)#10=1 S VCOMP=VCOMP_D
	S VCOMP=VCOMP_"*" I $D(E)#10=1 S VCOMP=VCOMP_E
	S VCOMP=VCOMP_"*" I $D(F)#10=1 S VCOMP=VCOMP_F
	S VCOMP=VCOMP_"*" I $D(G)#10=1 S VCOMP=VCOMP_G
	S VCOMP=VCOMP_"*/" Q
