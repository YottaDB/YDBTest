V1IO2	;I/O CONTROL -2-;KO-MM-TS,V1IO,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
542	W !,"I-542  effect on $X by output of graphics"
	S ITEM="I-542  "
	S VCOMP=XCOR(4)_"/"_XCOR(5)_"/"_XCOR(7)
	S VCORR=3_"/"_19_"/"_3
	D EXAMINER
	;
543	W !,"I-543  effect on $Y by output of graphics"
	S ITEM="I-543  "
	S VCOMP=YCOR(4)_"/"_YCOR(5)_"/"_YCOR(7)
	S VCORR=4_"/"_4_"/"_5
	D EXAMINER
	;
544	W !,"I-544  effect on $X by output of format parameter"
	S ITEM="I-544  "
	S VCOMP=XCOR(2)_"/"_XCOR(3)
	S VCORR=0_"/"_10
	D EXAMINER
	;
545	W !,"I-545  effect on $Y by output of format parameter"
	S ITEM="I-545  "
	S VCOMP=YCOR(2)_"/"_YCOR(3)
	S VCORR=2_"/"_3
	D EXAMINER
	;
546	W !,"I-546  $X in executing USE command"
	S ITEM="I-546  "
	S VCOMP=XCOR(1)_"/"_XCOR(6)_"/"_XCOR(8)
	S VCORR=4_"/"_19_"/"_4
	D EXAMINER
	;
547	W !,"I-547  $Y in executing USE command"
	S ITEM="I-547  "
	S VCOMP=YCOR(1)_"/"_YCOR(6)_"/"_YCOR(8)
	S VCORR=3_"/"_4_"/"_3
	D EXAMINER
	;
548	W !,"I-548  $IO and OPEN command"
	S ITEM="I-548  "
	S VCOMP=IO(548),VCORR=IO(0) D EXAMINER
	;
549	W !,"I-549  $IO and USE command"
	S ITEM="I-549  "
	S VCOMP=IO(5491)_IO(5490)_IO(5492)
	S VCORR=X_IO(0)_X D EXAMINER
	;
550	W !,"I-550  $IO and CLOSE command"
	S ITEM="I-550  "
	S VCOMP=IO(550),VCORR=IO(0) D EXAMINER
	;
551	W !,"I-551  $JOB and OPEN command"
	S ITEM="I-551  ",VCOMP=JOB(551),VCORR=JOB(0) D EXAMINER
	;
552	W !,"I-552  $JOB and USE command"
	S ITEM="I-552  "
	S VCOMP=JOB(5521)_JOB(5520)_JOB(5522)
	S VCORR=JOB(0)_JOB(0)_JOB(0) D EXAMINER
	;
553	W !,"I-553  $JOB and CLOSE command"
	S ITEM="I-553  ",VCOMP=JOB(553),VCORR=JOB(0) D EXAMINER
	;
554	W !,"I-554  $JOB and current IO device"
	S ITEM="I-554  ",VCOMP=""
	F I=532,533,534,5380,5381,5390,5391,5400,5401,5411,5412,5413,551,5521,5520,5522,553 S VCOMP=VCOMP_(JOB(0)=JOB(I))
	S VCORR="11111111111111111" D EXAMINER
	;
END	QUIT
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
