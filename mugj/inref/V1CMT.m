V1CMT	;COMMENT;YS-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	W !!,"V1CMT: TEST COMMENT",!
186	W !,"I-186  Comment coming after ls  (visual)"
	;W !,"** FAIL  I-186"
	W !,"   PASS  I-186"
	W !,"I-187  Comment coming after label ls  (visual)"
COMMENT	;W !,"** FAIL  I-187"
	W !,"   PASS  I-187"
188	W !,"I-188  Comment coming after command argument  (visual)" ; W !,"** FAIL  I-188"
	W !,"   PASS  I-188"
189	W !,"I-189  Comment coming after argumentless command with postconditional  (visual)"
	K:1  ;W !,"** FAIL  I-189"
	W !,"   PASS  I-189"
190	W !,"I-190  Comment coming after argumentless command without postconditional  (visual)"
	I 1 I  ;W !,"** FAIL  I-190"
	W !,"   PASS  I-190"
END	W !!,"END OF V1CMT",!
	S ROUTINE="V1CMT",TESTS=5,AUTO=0,VISUAL=5 D ^VREPORT
