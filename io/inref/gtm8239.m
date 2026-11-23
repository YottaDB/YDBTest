;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	;
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
	; case17 needs the signal to arrive while this process is inside the READ below. Only then does this process end up
	; at the direct mode prompt that the subtest waits for. A signal that arrives before the READ starts only writes
	; "hey", and the READ then waits for the full 100 seconds. So for case17 (zintr is not set), ask the interrupter
	; to wait until this process is inside the READ. case18 and case19 halt in $zinterrupt either way.
	do ^job("interrupter^gtm8239",1,""""_$job_","_usr1Val_","_$get(pipe)_","_('$get(zintr))_"""")
	lock -intr
	read line:100
	write "TEST-E-FAIL, Process did not get interrupted in 100 seconds"
	quit

interrupter(pid,signal,pipe,inread)
	lock +intr
	hang $random(10)/20
	do:$get(inread) waitinread(pid)
	if $zsigproc(pid,signal)
	do ^waitforproctodie(pid,100)
	if (pipe) do
	.	set file="alive"
	.	open file
	.	close file:delete
	quit

; Wait until process "pid" is inside a READ that waits for input. Such a process is blocked, which shows as state "S" in
; /proc/<pid>/stat, in the poll() of the READ timeout, which shows as a kernel function with "poll" in its name in
; /proc/<pid>/wchan. State "S" alone is not enough, as a process that is blocked for any other reason (for example in a
; HANG, a write to the terminal or a lock) is in state "S" too. A process that has not reached the READ yet is running
; or waiting for a CPU (state "R"), or is blocked elsewhere (another "wchan"). The two files are read one after the
; other, not at the same moment, so require state "S" and a "wchan" with "poll" in its name in 3 checks in a row.
; Give up after 600 checks (30 seconds), for example on a kernel that does not show "wchan", and let the caller send
; the signal anyway.
waitinread(pid)
	new cnt,i,line,state,wchan
	set cnt=0
	for i=1:1:600 do  quit:cnt=3  hang 0.05
	.	set line=$$readfile("/proc/"_pid_"/stat")
	.	; the state is the first field after the command name, and the command name is inside parentheses
	.	set state=$piece($piece(line,") ",$length(line,") "))," ",1)
	.	set wchan=$$readfile("/proc/"_pid_"/wchan")
	.	set cnt=$select((state="S")&(wchan["poll"):cnt+1,1:0)
	quit

; Return the first line of file "file"
readfile(file)
	new line
	open file:readonly
	use file
	read line
	close file
	quit line

emptyPipe
	set case=+$zcmdline
	set file="alive"
	for i=1:1:100 do
	.	open file:readonly
	.	close file
	.	hang 1
	quit
