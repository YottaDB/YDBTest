;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c003274	;
	set ^c003274=$job
	set ^done=0
	zshow "D":device
	if device("D",1)'["0 OPEN RMS" do  quit
	. write "TEST-F-FAIL - $P is not '0 OPEN RMS'",!
	. zwrite device
	write "c003274 started",! set ^start=$horolog
	do ^job("load^c003274",1,"""""")
	write "c003274 job complete",!,! set ^stop=$horolog
	quit

load	;
	write "in load, process = ",$JOB,!
	for   quit:^done  hang 1
	quit

; Validate that the two jobexam files exist
verify
	new file,filepattern,i,pidsep
	set pidsep="_"_^c003274_"_"
	set filepattern="YDB_JOBEXAM.ZSHOW_DMP"_pidsep_"*"
	if $zsearch("/dev/null",17)
	for i=1:1 set file=$zsearch(filepattern,17) quit:""=file  do
	. write $zpiece(file,pidsep,1),"_MASKED_",$zpiece(file,pidsep,2),!
	quit

; End the test
alldone set ^done=1 quit

; Send an interrupt to the parent
intrpt
	new i,intrptcnt,sigusr1,waitstatus,waittime
	set waittime=10,waitstatus=-1
	set intrptcnt=$increment(^intrptcnt)
	; Get value of SIGUSR1
	if $&gtmposix.signalval("SIGUSR1",.sigusr1)
	; titan and carmen get here frequently before the first process was setup
	for i=1:1:60 quit:$data(^c003274)  hang 0.25
	if 0=$data(^c003274),$zjobexam() quit
	; Send interrupt and wait for 10 seconds for the jobexam file. If none found, try once more
	for i=1:1:2 quit:(0=waitstatus)!(1=^done)  do
	. if $zsigproc(^c003274,sigusr1)
	. set ^intrpt($job,$horolog)=i
	. set waitstatus=$$FUNC^waitforfilecreate("YDB_JOBEXAM.ZSHOW_DMP_"_^c003274_"_"_intrptcnt,waittime)
	if waitstatus>0,$zjobexam()
	quit
