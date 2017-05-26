;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
concur
	;
start
	set numjobs=$zcmdline
	set jmaxwait=0
	set ^count=numjobs
	do ^job("job^concur",numjobs,"""""")
	quit

stopone
	set ^count=^count-1
	quit

stopall
	set ^count=0
	do wait^job
	quit

job()
	hang $random(9)/10
	for  quit:(^count<jobindex)  do ^fill(0,jobindex)
	quit
