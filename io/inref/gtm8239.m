;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper script for the io/gtm8239 to test various scenarios with interrupted READs and WRITEs, ensuring that they do not result in
; nested GT.M I/O invocations and other abnormalities.
case9
case8
case7
	if $&ydbposix.signalval("SIGQUIT",.quitVal)
	lock +intr
	set jmaxwait=0
	do ^job("interrupter^gtm8239",1,""""_$job_","_quitVal_","_0_"""")
	lock -intr
	for i=1:1:10000000  write "Iteration # ",i,!
	write "TEST-E-FAIL, Process did not get killed in 10M iterations"
	quit

case12
	set pipe=1
case11
	use:('$get(pipe)) $principal:follow
	set $etrap="write $zstatus,! zhalt 1"
case10
	if $&ydbposix.signalval("SIGUSR1",.usr1Val)
	set $zinterrupt="set x=1/0"
	lock +intr
	set jmaxwait=0
	do ^job("interrupter^gtm8239",1,""""_$job_","_usr1Val_","_$get(pipe)_"""")
	lock -intr
	read line:100
	write "TEST-E-FAIL, Process did not get interrupted in 100 seconds"
	quit

case13
	set $zroutines=".*"
	zsystem "chmod 000 ydb-relinkctl*; $gtm_dist/mupip rundown -relinkctl ."
	quit

case16
	set pipe=1
case15
	use:('$get(pipe)) $principal:follow
case14
	if $&ydbposix.signalval("SIGTERM",.termVal)
	lock +intr
	set jmaxwait=0
	do ^job("interrupter^gtm8239",1,""""_$job_","_termVal_","_$get(pipe)_"""")
	lock -intr
	for i=1:1:10000000 read line:0
	write "TEST-E-FAIL, Process did not get interrupted before 10M reads"
	quit

case19
	set pipe=1
case18
	set $etrap="write $zstatus,! zhalt 1"
	use:('$get(pipe)) $principal:follow
	set $zinterrupt="write ""hey"",! zhalt 0"
	set zintr=1
case17
	if $&ydbposix.signalval("SIGUSR1",.usr1Val)
	set:('$get(zintr)) $zinterrupt="write ""hey"",!"
	lock +intr
	set jmaxwait=0
	do ^job("interrupter^gtm8239",1,""""_$job_","_usr1Val_","_$get(pipe)_"""")
	lock -intr
	read line:100
	write "TEST-E-FAIL, Process did not get interrupted in 100 seconds"
	quit

interrupter(pid,signal,pipe)
	lock +intr
	hang $random(10)/20
	if $zsigproc(pid,signal)
	do ^waitforproctodie(pid,100)
	if (pipe) do
	.	set file="alive"
	.	open file
	.	close file:delete
	quit

emptyPipe
	set case=+$zcmdline
	set file="alive"
	for i=1:1:100 do
	.	open file:readonly
	.	close file
	.	hang 1
	quit
