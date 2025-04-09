;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/ydb908.csh
;
ydb908	;
	do init
	do test1
	do test2
	do test3
	do test4
	quit

init	;
	for keyword="UTIME","STIME","CUTIME","CSTIME","CPUTIM" set keyword(keyword)=13+$increment(counter)
	quit

test1	;
	new expected,actual,i
	set keyword="" for  set keyword=$order(keyword(keyword)) quit:keyword=""  do
	. write "# Test $ZGETJPI(PID,",keyword,") treats PID of 0 as PID of $JOB",!
	. ; In the below code, we check that $ZGETJPI($JOB) is the same as $ZGETJPI(0).
	. ; But since those 2 $ZGETJPI calls are separate operations, it is possible that the
	. ; current process' CPU time usage increases by 1 resulting in the two values being different.
	. ; To account for this possibility, we do this check 10 times and if we see the 2 values identical
	. ; at least once we consider this test to pass. Otherwise we signal a failure.
	. set pass=0
	. for i=1:1:10 do  quit:pass
	. . set expected(keyword,i)=$zgetjpi($job,keyword)
	. . set actual(keyword,i)=$zgetjpi(0,keyword)
	. . if expected(keyword,i)=actual(keyword,i) write "PASS",! set pass=1
	. if 'pass do
	. . write "test1 : TEST-E-FAIL : $ZGETJPI($JOB,",keyword,")'=$ZGETJPI(0,",keyword,") in 10 tries.",!
	. . zwrite expected,actual
	quit

test2	;
	new pid,expected,actual
	set pid=(2**32)	; this is guaranteed to be a non-existent pid
	set keyword="" for  set keyword=$order(keyword(keyword)) quit:keyword=""  do
	. write "# Test $ZGETJPI(PID,",keyword,") returns -1 in case of a non-existent PID",!
	. set expected=-1
	. set actual=$zgetjpi(pid,keyword)
	. if expected'=actual do
	. . write "test2 : TEST-E-FAIL : $ZGETJPI(",pid,",",keyword,") : Expected=",expected," : Actual=",actual,!
	. else  write "PASS",!
	quit

test3	;
	new pid,expected,actual,line,nlines,utime,stime,cutime,cstime,cputim
	set pid=1
	do piperead("/proc/"_pid_"/stat")	; "line()" and "nlines" will be populated after the call
	set keyword="" for  set keyword=$order(keyword(keyword)) quit:keyword=""  do
	. write "# Test $ZGETJPI(",pid,",",keyword,") matches what exists in /proc/",pid,"/stat for <init> process (i.e. PID=1)",!
	. set utime=$piece(line(1)," ",keyword("UTIME"))
	. set stime=$piece(line(1)," ",keyword("STIME"))
	. set cutime=$piece(line(1)," ",keyword("CUTIME"))
	. set cstime=$piece(line(1)," ",keyword("CSTIME"))
	. set cputim=utime+stime+cutime+cstime
	. set expected=$select("CPUTIM"'=keyword:$piece(line(1)," ",keyword(keyword)),1:cputim)
	. set actual=$zgetjpi(pid,keyword)
	. if '$$timeIsAlmostSame(expected,actual) do
	. . write "test3 : TEST-E-FAIL : $ZGETJPI(",pid,",",keyword,") : Expected=",expected," : Actual=",actual,!
	. else  write "PASS",!
	quit

test4	;
	new i,line,nlines,file,actual
	do piperead("/proc/*/stat")	; "line()" and "nlines" will be populated after the call
	set file="test4.out"	; use this file to record the non-deterministic $zgetjpi output of all pids in the system.
				; Having the extension ".out" ensures test framework will catch any "%YDB-E-"/"%YDB-F-" errors.
	open file:(newversion)
	set keyword="" for  set keyword=$order(keyword(keyword)) quit:keyword=""  do
	. use $principal
	. write "# Test $ZGETJPI(PID,",keyword,") does not SIG-11 or assert fail or error for arbitrary list of PIDs found to exist in the system",!
	. use file
	. for i=1:1:nlines set pid=$piece(line(i)," ",1) do
	. . write "# Test $ZGETJPI(",pid,",",keyword,") does not SIG-11 or assert fail or error for arbitrary list of PIDs found to exist in the system",!
	. . set actual=$zgetjpi(pid,keyword)
	. use $principal
	. write "PASS",!
	quit

piperead(dev);
	kill line,nlines
	open dev:(command="cat /proc/*/stat":readonly)::"PIPE"
	use dev
	for  read line($increment(nlines)) quit:$zeof
	kill line(nlines) if $increment(nlines,-1)
	close dev
	quit

timeIsAlmostSame(expected,actual)
	; We check if the two values are the same but allow for them to be different by a close margin of 1%
	; This is because the "init" process would be accumulating CPUTIM etc. all the time and so it is possible
	; the "cat /proc/1/stat" and $zgetjpi(1,"CPUTIM") calls get different values. We expect the two values to
	; be very close to each other.
	if expected=actual quit 1
	quit (expected/actual)>0.99

