;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JNLBAS0	; JNL test with KILL and SET
	Write !!,"JNLBAS0 test with KILL and SET "
	View "GDSCERT":1
	Set job=$JOB
	Set ^JOB=job
	Set ITEM="JNLBAS0 - no wait "
	Write !,ITEM,pass," passes ",!
	Set mark=job*pass,maxnod=500,maxlen=120,lenidx=0,FAIL=0
	Set exam=pass\16   If exam=0  Set exam=1
	Kill ^b(job),^bcnt
	For i=1:1:pass   Do proc0   If i#exam=0  Set ^bcnt(0,i)=i  Do EXAMIN(i)
	Set ITEM="JNLBAS0 random wait "
	Write !,ITEM,pass," passes ",!
	Kill ^b(job)
	For i=1:1:pass   Do proc1   If i#exam=0  Set ^bcnt(1,i)=i  Do EXAMIN(i)
	Write !,"JNLBAS0 COMPLETE"
	Quit

proc0	Kill ^b(job)
	If $DATA(^b(job))'=0		Do TRACE(0,$DATA(^b(job)),0)  Quit
	Set x=$ORDER(^b(job-1))
	If x'="",x<(job+1)		Do TRACE(1,$ORDER(^b(job-1)),"")  Quit
	Set (top,^b(job))=mark,mark=mark+1
	Set (left,^(job,1))=mark,mark=mark+1
	Set (right,^(3))=mark,mark=mark+1
	For i1=1:1:i#maxnod   Set lenidx=lenidx+1#maxlen,^b(job,2,i1)=$JUSTIFY("",lenidx)
	Do chktop
	If i#maxnod=0,$DATA(^b(job,2))'=0  Do TRACE(2,$DATA(^b(job,2)),0)  Quit
	If i#maxnod,$DATA(^b(job,2))'=10  Do TRACE(3,$DATA(^b(job,2)),10) Quit
	For i1=1:i#10+1:i#maxnod   Kill ^b(job,2,i1)
	Do chktop
	Kill ^b(job,2)
	Do chktop
	Quit

proc1	Kill ^b(job)
	Hang $RANDOM(3)
	If $DATA(^b(job))'=0		Do TRACE(0,$DATA(^b(job)),0)  Quit
	Hang $RANDOM(3)
	Set x=$ORDER(^b(job-1))
	If x'="",x<(job+1)		Do TRACE(1,$ORDER(^b(job-1)),"")  Quit
	Hang $RANDOM(3)
	Set (top,^b(job))=mark,mark=mark+1
	Hang $RANDOM(3)
	Set (left,^(job,1))=mark,mark=mark+1
	Hang $RANDOM(3)
	Set (right,^(3))=mark,mark=mark+1
	Hang $RANDOM(3)
	For i1=1:1:i#maxnod  Set lenidx=lenidx+1#maxlen,^b(job,2,i1)=$JUSTIFY("",lenidx)
	Hang $RANDOM(3)
	Do chktop
	Hang $RANDOM(3)
	If i#maxnod=0,$DATA(^b(job,2))'=0	Do TRACE(2,$DATA(^b(job,2)),0)  Quit
	If i#maxnod,$DATA(^b(job,2))'=10	Do TRACE(3,$DATA(^b(job,2)),10) Quit
	Do chktop
	Hang $RANDOM(3)
	Kill ^b(job,2)
	Hang $RANDOM(3)
	Do chktop
	Quit

chktop	If $DATA(^b(job))'=11		Do TRACE(4,$DATA(^b(job)),11)	Quit
	Set x=$ORDER(^b(job-1))
	If x'=job			Do TRACE(5,x,job)		Quit
	If $DATA(^(job))'=11 		Do TRACE(6,$DATA(^(job)),11)	Quit
	If ^(job)'=top 			Do TRACE(7,^(job),top)		Quit
	If $DATA(^(job,1))'=1 		Do TRACE(8,$DATA(^(job,1)),1)	Quit
	If ^(1)'=left 			Do TRACE(9,^(1),left)		Quit
	If $DATA(^(3))'=1 		Do TRACE(10,$DATA(^(3)),1)	Quit
	If ^(3)'=right 			Do TRACE(11,^(3),right)		Quit
	If $ORDER(^(3))'="" 		Do TRACE(12,$ORDER(^(3)),"")	Quit
	If $ORDER(^(""))'=1 		Do TRACE(13,$ORDER(^("")),1)	Quit
	Quit

EXAMIN(cnt)
	Write "."   If cnt#4=0  Write " "
	Write:$Y>55 #
	Halt:$DATA(^STOP)
	Quit

TRACE(LBL,VCOMP,VCORR)
	Set FAIL=FAIL+1,q=$HOROLOG
	Write !,"** FAIL ",FAIL," in ",ITEM,LBL,", ",i,"-th pass at ",$ZDATE(q,"24:60:SS")
	Write:$Y>55 #
	Write !,"           COMPUTED =""",VCOMP,""""  Write:$Y>55 #
	Write !,"           CORRECT  =""",VCORR,""""  Write:$Y>55 #
	Write !
	Quit
