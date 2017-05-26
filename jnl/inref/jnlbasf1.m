JNLBASF1	; JNL check of data after JNLBASF
	Write !!,"JNLBASF1 check of data after recovery ",!
	Set ITEM="JNLBASF1 check of data after recovery ",err=0
	Set job=^JOB
	Set top=pass*(job+3)-3
	Set left=top+1
	Set right=top+2
	Do chktop
	If err=0  Write "PASS ",!
	Quit

chktop	If $DATA(^b(job))'=11	Do TRACE(4,$DATA(^b(job)),11)	Quit
	Set x=$ORDER(^b(job-1))
	If x'=job		Do TRACE(5,x,job)		Quit
	If $DATA(^(job))'=11 	Do TRACE(6,$DATA(^(job)),11)	Quit
	If ^(job)'=top		Do TRACE(7,^(job),top)		Quit
	If $DATA(^(job,1))'=1 	Do TRACE(8,$DATA(^(job,1)),1)	Quit
	If ^(1)'=left		Do TRACE(9,^(1),left)		Quit
	If $DATA(^(3))'=1 	Do TRACE(10,$DATA(^(3)),1)	Quit
	If ^(3)'=right		Do TRACE(11,^(3),right)		Quit
	If $ORDER(^(3))'="" 	Do TRACE(12,$ORDER(^(3)),"")	Quit
	If $ORDER(^(""))'=1 	Do TRACE(13,$ORDER(^("")),1)	Quit
	Quit

TRACE(LBL,VCOMP,VCORR)
	Set q=$HOROLOG
	Set err=err+1
	Write !,"** FAIL  in ",ITEM,LBL,",  at ",$ZDATE(q,"24:60:SS")
	Write:$Y>55 #
	Write !,"           COMPUTED =""",VCOMP,""""   Write:$Y>55 #
	Write !,"           CORRECT  =""",VCORR,""""   Write:$Y>55 #
	Write !
	Quit
