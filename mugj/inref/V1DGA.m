V1DGA	;$DATA, KILL (GLOBAL VARIABLES) -1-;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1DGA : TEST OF $DATA FUNCTION AND KILL COMMAND ON GLOBAL VARIABLES -1-",!
822	W !,"I-822  KILLing undefined unsubscripted global variables"
	S ITEM="I-822  ",VCOMP=""
	KILL ^V1A,^V1B,^V1C,^V1D,^V1E,^V1F,^V1G D DATA
	K ^V1A D DATA K ^V1A,^V1B,^V1C,^V1D,^V1E,^V1F,^V1G D DATA
	S VCORR="0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
192	W !,"I-191/192  The value of $DATA of SET unsubscripted global variables"
	S ITEM="I-191/192  ",VCOMP=""
	S ^V1A=1 D DATA S ^V1A=1,^V1D="A",^V1B=2 D DATA
	S VCORR="1 0 0 0 0 0 0 *1*******/1 1 0 1 0 0 0 *1*2**A****/" D EXAMINER
	;
193	W !,"I-193/194  The value of $DATA of KILLing unsubscripted global variables"
	S ITEM="I-193/194  ",VCOMP=""
	K ^V1A D DATA K ^V1B,^V1D D DATA
	S VCORR="0 1 0 1 0 0 0 **2**A****/0 0 0 0 0 0 0 ********/" D EXAMINER
	;
195	W !,"I-195  Assign numeric literal to unsubscripted global variables"
	S ITEM="I-195  ",VCOMP=""
	S ^V1A=111,^V1D=0009800,^V1B=12345678,^V1C=987.654,^V1F=0.00,^V1E=000.8900 D DATA
	K ^V1A,^V1B,^V1C D DATA
	S VCORR="1 1 1 1 1 1 0 *111*12345678*987.654*9800*.89*0**/0 0 0 1 1 1 0 ****9800*.89*0**/"
	D EXAMINER
	;
196	W !,"I-196  Assign string literal to unsubscripted global variables"
	S ITEM="I-196  ",VCOMP=""
	S ^V1A="ABC",^V1D="  ",^V1B="",^V1C="00234.00" D DATA
	K ^V1B,^V1E,^V1F D DATA
	S VCORR="1 1 1 1 1 1 0 *ABC**00234.00*  *.89*0**/1 0 1 1 0 0 0 *ABC**00234.00*  ****/" D EXAMINER
	;
197	W !,"I-197  Effect on global variables by killing local variables"
	S ITEM="I-197  ",VCOMP=""
	K A,B,C,D,E,F,G K V1A,V1B,V1C,V1D,V1E,V1F,V1G D DATA
	S VCORR="1 0 1 1 0 0 0 *ABC**00234.00*  ****/" D EXAMINER
	;
198	W !,"I-198  Effect on global variables by executing exclusive kill"
	S ^PASS=PASS,^FAIL=FAIL
	K (PASS,FAIL,X,Y,Z,V1A,V1B) S VCOMP="" D DATA
	S VCORR="1 0 1 1 0 0 0 *ABC**00234.00*  ****/"
	I (^PASS'=PASS)!(^FAIL'=FAIL) W !,"** FAIL  I-198  executing exclusive kill"
	S ITEM="I-198  " D EXAMINER
	;
199	W !,"I-199  Effect on global variables by executing kill all local variable"
	S ^PASS=PASS,^FAIL=FAIL K  ;kill all local variable
	S PASS=^PASS,FAIL=^FAIL S ITEM="I-199  ",VCOMP="" D DATA
	S VCORR="1 0 1 1 0 0 0 *ABC**00234.00*  ****/" D EXAMINER
	;
200	W !,"I-200  Allowed global variable name"
	S ITEM="I-200  "
	S ^GLOBAL00=" ^GLOBAL00 ",^Z0000000=" ^Z0000000 "
	S VCOMP=$D(^GLOBAL00)_^GLOBAL00_$D(^Z0000000)_^Z0000000
	S VCORR="1 ^GLOBAL00 1 ^Z0000000 " D EXAMINER
	KILL ^GLOBAL00,^Z0000000
	;
END	W !!,"END OF V1DGA",!
	S ROUTINE="V1DGA",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  K ^PASS,^FAIL,^V1A,^V1B,^V1C,^V1D,^V1E,^V1F,^V1G Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
	;
DATA	S VCOMP=VCOMP_$D(^V1A)_" "_$D(^V1B)_" "_$D(^V1C)_" "_$D(^V1D)_" "_$D(^V1E)_" "_$D(^V1F)_" "_$D(^V1G)_" "
	S VCOMP=VCOMP_"*" I $D(^V1A)#10=1 S VCOMP=VCOMP_^V1A
	S VCOMP=VCOMP_"*" I $D(^V1B)#10=1 S VCOMP=VCOMP_^V1B
	S VCOMP=VCOMP_"*" I $D(^V1C)#10=1 S VCOMP=VCOMP_^V1C
	S VCOMP=VCOMP_"*" I $D(^V1D)#10=1 S VCOMP=VCOMP_^V1D
	S VCOMP=VCOMP_"*" I $D(^V1E)#10=1 S VCOMP=VCOMP_^V1E
	S VCOMP=VCOMP_"*" I $D(^V1F)#10=1 S VCOMP=VCOMP_^V1F
	S VCOMP=VCOMP_"*" I $D(^V1G)#10=1 S VCOMP=VCOMP_^V1G
	S VCOMP=VCOMP_"*/" Q
