VV2READ	;READ COUNT;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2READ: TEST OF READ COUNT "
140	W !!,"II-140  Terminated by readcount characters" S ITEM="II-140"
	read !,"   read X#3 : TYPE ""ABC"" AND NEVER TOUCH THE <CR> KEY >",X#3
	S VCOMP=X S VCORR="ABC" D EXAMINER
	;
141	W !!,"II-141  Terminated by <CR>" S ITEM="II-141"
	r !,"   r X#10 : TYPE ""ABC"" AND <CR> KEY >",X#10
	S VCOMP=X S VCORR="ABC" D EXAMINER
	;
142	W !!,"II-142  Indirection argument" S ITEM="II-142"
	S A="@B#COUNT",B="X",COUNT=10
	R !,"   @A (R X#10) : TYPE ""ABC"" AND <CR> KEY >",@A
	S VCOMP=X S VCORR="ABC" D EXAMINER
	;
143	W !!,"II-143  Terminated by readcount characters" S ITEM="II-143"
	r !,"   r X#3:60 : TYPE ""ABC"" ONLY WITHIN 60 SECONDS >",X#3:60
	S VCOMP=$T_" "_X S VCORR="1 ABC" D EXAMINER
	;
144	W !!,"II-144  Terminated by <CR>" S ITEM="II-144"
	rEAD !,"   rEAD X#10:60 : TYPE ""ABC"" AND <CR> KEY >",X#10:60
	S VCOMP=$T_" "_X S VCORR="1 ABC" D EXAMINER
	;
145	W !!,"II-145  Terminated by timeout" S ITEM="II-145"
	R !,"   R X#10:15 : TYPE ""ABC"" ONLY WITHIN 15 SECONDS >",X#10:15
	S VCOMP=$T_" "_X S VCORR="0 ABC" D EXAMINER
	;
146	W !!,"II-146  Test of $TEST  when timeout time is 0" S ITEM="II-146"
	R !,"   R X#10:0 : NEVER TOUCH ANY KEY >",X#10:0
	S VCOMP=$T_X S VCORR="0" D EXAMINER
	;
147	W !!,"II-147  Indirection argument" S ITEM="II-147"
	S A="@B#@C:TIME",B="X",C="COUNT",COUNT=10,TIME=60.4
	R !,"   @A (R X#10:60.4) : TYPE ""ABC"" AND <CR> KEY >",@A
	S VCOMP=$T_" "_X S VCORR="1 ABC" D EXAMINER
	;
END	W !!,"END OF VV2READ",!
	S ROUTINE="VV2READ",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
