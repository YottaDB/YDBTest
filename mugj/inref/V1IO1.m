V1IO1	;I/O CONTROL -1-;KO-MM-TS,V1IO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
532	W !,"I-532/535  OPEN command syntax and operation"
	S ITEM="I-532/535  "
	S VCOMP=JOB(532)_"/"_IO(532)_"/"_XCOR(532)_"/"_YCOR(532)
	S VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
	D EXAMINER
	;
533	W !,"I-533/536  USE command syntax and operation"
	S ITEM="I-533/536  "
	S VCOMP=JOB(533)_"/"_IO(533)_"/"_XCOR(533)_"/"_YCOR(533)
	S VCORR=JOB(0)_"/"_X_"/"_0_"/"_0
	D EXAMINER
	;
534	W !,"I-534/537  CLOSE command syntax and operation"
	S ITEM="I-534/537  "
	S VCOMP=JOB(534)_"/"_IO(534)_"/"_XCOR(534)_"/"_YCOR(534)
	S VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
	D EXAMINER
	;
538	W !,"I-538  postconditional of OPEN command"
	S ITEM="I-538  ",VCOMP=""
	S VCOMP=VCOMP_JOB(5380)_"/"_IO(5380)_"/"_XCOR(5380)_"/"_YCOR(5380)_"/"
	S VCOMP=VCOMP_JOB(5381)_"/"_IO(5381)_"/"_XCOR(5381)_"/"_YCOR(5381)
	S VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
	D EXAMINER
	;
539	W !,"I-539  postconditional of USE command"
	S ITEM="I-539  ",VCOMP=""
	S VCOMP=VCOMP_JOB(5390)_"/"_IO(5390)_"/"_XCOR(5390)_"/"_YCOR(5390)_"/"
	S VCOMP=VCOMP_JOB(5391)_"/"_IO(5391)_"/"_XCOR(5391)_"/"_YCOR(5391)
	S VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_JOB(0)_"/"_X_"/"_0_"/"_0
	D EXAMINER
	;
540	W !,"I-540  postconditional of CLOSE command"
	S ITEM="I-540  ",VCOMP=""
	S VCOMP=VCOMP_JOB(5400)_"/"_IO(5400)_"/"_XCOR(5400)_"/"_YCOR(5400)_"/"
	S VCOMP=VCOMP_JOB(5401)_"/"_IO(5401)_"/"_XCOR(5401)_"/"_YCOR(5401)
	S VCORR=JOB(0)_"/"_X_"/"_0_"/"_0_"/"_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)
	D EXAMINER
	;
541	W !,"I-541  timeout of OPEN command"
	S ITEM="I-541  ",VCOMP=""
	S VCOMP=VCOMP_JOB(5411)_"/"_IO(5411)_"/"_XCOR(5411)_"/"_YCOR(5411)_"/"_T(5411)_"/"
	S VCOMP=VCOMP_JOB(5412)_"/"_IO(5412)_"/"_XCOR(5412)_"/"_YCOR(5412)_"/"_T(5412)_"/"
	S VCOMP=VCOMP_JOB(5413)_"/"_IO(5413)_"/"_XCOR(5413)_"/"_YCOR(5413)_"/"_T(5413)
	S VCORR=JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_1_"/"_JOB(0)_"/"_X_"/"_0_"/"_0_"/"_1_"/"_JOB(0)_"/"_IO(0)_"/"_XCOR(0)_"/"_YCOR(0)_"/"_1
	D EXAMINER
	;
END	QUIT
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
