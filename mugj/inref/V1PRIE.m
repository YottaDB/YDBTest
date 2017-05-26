V1PRIE	;-RP- IF AND ELSE COMMAND;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1PRIE: PRELIMINARY TEST OF IF & ELSE COMMAND",!
731	W !,"I-731/733  interpretation of ifargument and ELSE command"
	S ITEM="I-731/733.1  ifargument is 0 "
	IF 0 S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 1 " W:$Y>55 # ELSE  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 2 " W:$Y>55 #
	ELSE  S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	;
	S ITEM="I-731/733.2  ifargument is 1 "
	I 1 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 3" W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 4" W:$Y>55 #
	;
	S ITEM="I-731/733.3  ifargument is 2 "
	I 2 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 5" W:$Y>55 #
	;
	S ITEM="I-731/733.4  ifargument is -1 "
	I -1 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 6" W:$Y>55 #
	;
	S ITEM="I-731/733.5  ifargument is -0.00000001 "
	I -0.00000001 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 7" W:$Y>55 #
	;
	S ITEM="I-731/733.6  list of IF command and all ifargument is true"
	I 1 I 2 I 3 I 4 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 8 " W:$Y>55 #
	;
	S ITEM="I-731/733.7  list of IF command and a ifargument is false"
	I 1 I 2 I 0 I 4 S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 9" W:$Y>55 #
	E  S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	;
732	W !,"I-732/733  ELSE command and argument list of IF command "
	S ITEM="I-732/733.1  all ifargument is true"
	I 1,2,3,-4,5 S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	E  S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 10" W:$Y>55 #
	;
	S ITEM="I-732/733.2  a ifargument is false"
	I 1,-2,3,0,4 S FAIL=FAIL+1 W !,"** FAIL  ",ITEM,"ERROR 11" W:$Y>55 #
	E  S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 #
	;
END	W !!,"END OF V1PRIE",!
	S ROUTINE="V1PRIE",TESTS=9,AUTO=9,VISUAL=0 D ^VREPORT
	K  Q
