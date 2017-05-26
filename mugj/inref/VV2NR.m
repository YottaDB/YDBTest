VV2NR	;NAKED REFERENCE;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	W !!,"VV2NR: TEST OF NAKED REFERENCES",!
136	W !,"II-136  Effect of naked reference on KILL command"
	S ITEM="II-136  ",VCOMP=""
	K ^VV,^VV(1) S ^(1)=1 S VCOMP=^VV(1)
	S VCORR="1" D EXAMINER
	;
137	W !,"II-137  Effect of naked reference on $DATA function"
	S ITEM="II-137  ",VCOMP=""
	K ^VV S VCOMP=$D(^VV(1))_" " S ^(2)=2 S VCOMP=VCOMP_^VV(2)
	S VCORR="0 2" D EXAMINER
	;
138	W !,"II-138  Effect of global reference in $DATA on naked indicator"
	S ITEM="II-138  ",VCOMP=""
	K ^VV,^VV(1,1) S ^(2)="X" S VCOMP=$D(^(2,3))_" " S ^(4)=3 S VCOMP=VCOMP_^VV(1,2,4)
	S VCORR="0 3" D EXAMINER
	;
139	W !,"II-139  Interpretation sequence of SET command"
	S ITEM="II-139  ",VCOMP=""
	K ^VV S ^($D(^VV(0)))=$D(^(0)) S VCOMP=^VV(0)
	S VCORR="0" D EXAMINER
	;
END	W !!,"END OF VV2NR",!
	S ROUTINE="VV2NR",TESTS=4,AUTO=4,VISUAL=0 D ^VREPORT
	K  K ^VV Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
