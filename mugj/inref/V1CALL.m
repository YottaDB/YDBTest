V1CALL	;DO (CALL) COMMAND;KO-TS,V1CALL,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0
	W !!,"V1CALL : TEST OF DO command ( call external routine )",!
172	W !,"I-172  argument list"
	S ITEM="I-172  ",VCOMP=""
	DO 1^V1CALL1,2^V1CALL1,IF^V1CALL1
	S VCORR="1 2 IF " D EXAMINER
	;
173	W !,"I-173  ^routineref"
	S ITEM="I-173  ",VCOMP=""
	DO ^V1CALL1 S VCOMP=VCOMP_"CONTI"
	S VCORR="1 CONTI" D EXAMINER
	;
	W !!,"DO label^routineref",!
174	W !,"I-174  label^routineref  label is  alpha"
	S ITEM="I-174  ",VCOMP=""
	D AABBCC^V1CALL1 D Z^V1CALL1,DO^V1CALL1
	S VCORR="AABBCC Z DO " D EXAMINER
	;
175	W !,"I-175  label^routineref  label is  intlit"
	S ITEM="I-175  ",VCOMP=""
	D 2^V1CALL1 D 012^V1CALL1,0^V1CALL1
	S VCORR="2 012 0 " D EXAMINER
	;
176	W !,"I-176  label^routineref  label is  % and alpha"
	S ITEM="I-176  ",VCOMP=""
	D %ABC^V1CALL1 DO %^V1CALL1
	S VCORR="%ABC % " D EXAMINER
	;
177	W !,"I-177  label^routineref  label is  % and digit"
	S ITEM="I-177  ",VCOMP=""
	D %0000000^V1CALL1,%2345678^V1CALL1
	S VCORR="%0000000 %2345678 " D EXAMINER
	;
	W !!,"DO label+intexpr^routineref",!
178	W !,"I-178  intexpr is positive integer"
	S ITEM="I-178  ",VCOMP=""
	D 2+1^V1CALL1 D %2345678+0002^V1CALL1,V1CALL1+08^V1CALL1
	S VCORR="3 Q 7 " D EXAMINER
	;
179	W !,"I-179  intexpr is zero"
	S ITEM="I-179  ",VCOMP=""
	DO ABCDEFGH+--"NUMBER"^V1CALL1
	S VCORR="ABCDEFGH " D EXAMINER
	;
180	W !,"I-180  intexpr is non-integer numlit"
	S ITEM="I-180  ",VCOMP=""
	D 012+3.99999^V1CALL1
	S VCORR="% " D EXAMINER
	;
181	W !,"I-181  intexpr contains binaryop"
	S ITEM="I-181  ",VCOMP=""
	D V1CALL1+7-11+12^V1CALL1
	S VCORR="7 " D EXAMINER
	;
182	W !,"I-182  intexpr contains unaryop"
	S ITEM="I-182  ",VCOMP=""
	D IF+'0^V1CALL1
	S VCORR="%0 " D EXAMINER
	;
183	W !,"I-183  intexpr is function"
	S ITEM="I-183  ",VCOMP=""
	D %2345678+$P("2,4,1,3^4",",",4)^V1CALL1
	S VCORR="%A1 " D EXAMINER
	;
184	W !,"I-184  intexpr is gvn"
	S ITEM="I-184  ",VCOMP=""
	S ^V1A=11 D 1+^V1A^V1CALL1
	S VCORR="AABBCC " D EXAMINER
	;
185	W !,"I-185  intexpr contains gvn as expratom"
	S ITEM="I-185  ",VCOMP=""
	S ^V1A=11 D Z+-20+^V1A+^V1A^V1CALL1
	S VCORR="%2345678 " D EXAMINER
	;
834	W !,"I-834  argument list ^routineref without postcondition"
	S ITEM="I-834  ",VCOMP=""
	D ^V1CALL1,^V1CALL1,^V1CALL1
	S VCORR="1 1 1 " D EXAMINER
	;
835	W !,"I-835  argument list label^routineref without postcondition"
	S ITEM="I-835  ",VCOMP=""
	D AABBCC^V1CALL1,Z^V1CALL1,DO^V1CALL1,%0000000^V1CALL1
	S VCORR="AABBCC Z DO %0000000 " D EXAMINER
	;
836	W !,"I-836  argument list label+intexpr^routineref without postcondition"
	S ITEM="I-836  ",VCOMP=""
	D 012+3.999^V1CALL1,%0A1B2C3+3^V1CALL1,ABCDEFGH+--"04ENUMBER"^V1CALL1,^V1CALL1
	S VCORR="% 10 01 1 " D EXAMINER
	;
END	W !!,"END OF V1CALL",!
	S ROUTINE="V1CALL",TESTS=17,AUTO=17,VISUAL=0 D ^VREPORT
	K  K ^V1A Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
