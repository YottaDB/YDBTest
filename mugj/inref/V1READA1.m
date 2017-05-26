V1READA1	;READ COMMAND -1-;KO-TS,V1READA,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	S PASS=0,FAIL=0 W:$Y>50 #
	W !!,"V1READA1: TEST READ COMMAND -1-",!
	W !,"TEST OF 'READ lvn' :"
	W !,"TYPE THE SPECIFIED KEYS ONLY, FOLLOWED BY <ENTER OR CR> KEY",!
749	W !,"I-749  readargument is string literal"
	S ITEM="I-749  "
	READ !!,"TEST I-749: TYPE 'MUMPS' AND <ENTRY> KEY",!,"   ",M S VCOMP=M
	S VCORR="MUMPS" D EXAMINER
	;
750	W !!,"I-750  readargument is format control characters"
	S ITEM="I-750  ",VCOMP=""
	R !!,"TEST I-750: TYPE :;<>?@ (EACH SEPARATED BY <ENTER>)"
	R !?10,%1,!?10,%2,!?10,%3,!?10,%4,!?10,%5,!?10,%6
	S VCOMP=%1_%2_%3_%4_%5_%6
	I %1=":",%2=";",%3="<",%4=">",%5="?",%6="@" S VCOMP=VCOMP_" ... PASSED"
	E  S VCOMP=VCOMP_" ... FAILED"
	S VCORR=":;<>?@ ... PASSED" D EXAMINER
	;
751	W !!,"I-751  Read empty string"
	S ITEM="I-751  ",VCOMP="ERROR"
	R !!,"TEST I-751: TYPE ONLY THE <ENTRY> KEY",VCOMP
	S VCORR="" D EXAMINER
	;
752	S V="" F I=1:1:255 S V=V_" "
	W !!,"I-752  Read 255 characters length data"
	S ITEM="I-752  ",VCOMP=""
	R !!,"TEST I-752:TYPE 255 SPACES AND <ENTRY> KEY",!,VCOMP
	S VCORR=V D EXAMINER
	;
753	W !!,"I-753  Read upper-case alphabetics"
	S ITEM="I-753  "
	READ !!,"TEST I-753: TYPE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' AND <ENTRY> KEY"
	W !,"                  " R % S VCOMP=%
	S VCORR="ABCDEFGHIJKLMNOPQRSTUVWXYZ" D EXAMINER
	;
754	W !!,"I-754  Read lower-case alphabetics"
	S ITEM="I-754  "
	R !!,"TEST I-754: TYPE 'abcdefghijklmnopqrstuvwxyz' AND <ENTRY> KEY",!,"                  ",%2345678 S VCOMP=%2345678
	S VCORR="abcdefghijklmnopqrstuvwxyz" D EXAMINER
	;
755	W !!,"I-755  Read punctuations"
	S ITEM="I-755  "
	R !!,"TEST I-755: TYPE ! ""#$%&'()*+,-./:;<=>?@[\]^_`{|}~  AND <ENTRY> KEY (NOTICE THE SPACE)",!,"                 ",%1A2B3C4 S VCOMP=%1A2B3C4
	S VCORR="! ""#$%&'()*+,-./:;<=>?@[\]^_`{|}~" D EXAMINER
	;
756	W !!,"I-756  Read numerics"
	S ITEM="I-756  "
	R !!,"TEST I-756: TYPE '1234567890' AND <ENTRY> KEY",!,"                  ",ABCDEFGH S VCOMP=ABCDEFGH
	S VCORR="1234567890" D EXAMINER
	;
END	W !!,"END OF V1READA1",!
	S ROUTINE="V1READA1",TESTS=8,AUTO=8,VISUAL=0 D ^VREPORT
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
