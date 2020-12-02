;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
closestatus
	; test the saving of close status for the PIPE device in $ZCLOSE
	write "Test1: use ""grep z"" as the only command in the pipeline.  Close status should be 0",!
	set p="pp"
	open p:(comm="grep z":WRITE)::"pipe"
	use p
	write "abcdefg",!
	write "matched: zzzzzzzzzzzzz",!
	close p:timeout=15
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test2: use ""grep z"" as the only command in the pipeline.  No match so close status should be 1",!
	open p:(comm="grep z":WRITE)::"pipe"
	use p
	write "abcdefg",!
	write "abcdefg",!
	close p:timeout=15
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test3: use the following pipeline: ""cat | tr a k | grep z"".  Close status should be 0",!
	open p:(comm="cat | tr i z | grep z")::"pipe"
	use p
	write "abcdefg",!
	write "matched: abcdefghi",!
	; we have to do the write /eof so "tr" will flush its output so we can read it from the pipe before close p
	write /eof
	read x
	use $p
	write x,!
	close p:timeout=15
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test4: use the following pipeline: ""cat | tr a k | grep z"".  No match so close status should be 1",!
	open p:(comm="cat | tr i z | grep z")::"pipe"
	use p
	write "abcdefg",!
	write "abcdefg",!
	; No output will be retured so we will just close the PIPE and read zeof
	close p:timeout=15
	write "PIPE close status = ",$ZCLOSE,!!

	; This part of the test tests close status when killing the PIPE device's child processes
	; First, a pipe device will be created using "delay_filter 1 2"
	; This routine just echos lines read to stdout until its input is closed
	; It then waits 1 sec to terminate and exits with a status of 2
	; Test the close status when doing a kill -9 of the process (25907) first sample line below
	;cronem   25907 25906 43 11:03 pts/3    00:00:00 tcsh -c delay_filter 1 2
	;cronem   25971 25907  0 11:03 pts/3    00:00:00 delay_filter 1 2
	; The pipe close status should be -9
	;
	; Next, a pipe device will be created using "delay_filter2 1 2".  This is just a copy of delay_filter
	; but we want to avoid any name conflicts when using ps
	; Test the close status when doing a kill -9 of the process (4676) second sample line below
	;cronem    4612  4611 11 10:11 pts/3    00:00:00 tcsh -c delay_filter2 1 2
	;cronem    4676  4612  0 10:11 pts/3    00:00:00 delay_filter2 1 2
	; The pipe close status is a normal return status and should be 137 or 128+9

	set p="pp"
	write "Test5: close status when killing the PIPE's child process",!!
	do openpipe(p,"delay_filter 1 2")
	do getchild(p,.ps,.linematch,"delay_filter")

	; kill this process (second field)
	zsystem "kill -9 "_ps(linematch,2)
	close p
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test6: close status when killing the PIPE's grandchild process",!!
	new ps,linematch
	do openpipe(p,"delay_filter2 1 2")
	do getchild(p,.ps,.linematch,"delay_filter2")

	; use the pid of this line (field 2) to find the ps line with
	; parent (field 3) equal to this pid (line 2 above)
	set parentpid=ps(linematch,2)

	set linematch=0
	for j=1:1:lines quit:linematch  do
	. if parentpid=ps(j,3) set linematch=j
	if 'linematch  do
	. use $p write "Problem finding delay_filter2 1 2 - stopping test",!
	. write "current process id = ",$job,!
	. write "ps -ef output for debugging:",!
	. for j=1:1:lines  write ps(j),!
	. halt

	; kill this process (second field)
	zsystem "kill -9 "_ps(linematch,2)
	hang 2
	close p
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test7: close status for normal termination of delay_filter 1 2",!!
	do openpipe(p,"delay_filter 1 2")
	do testpipe(p,"delay_filter",.totcom)
	close p:timeout=15
	write "PIPE close status = ",$ZCLOSE,!!

	write "Test8: close status for timeout=10 of delay_filter3 20 2",!!
	new ps,linematch
	do openpipe(p,"delay_filter3 20 2")
	do getchild(p,.ps,.linematch,"delay_filter3")

	; use the pid of this line (field 2) to find the ps line with
	; parent (field 3) equal to this pid (line 2 above)
	set parentpid=ps(linematch,2)

	set linematch=0
	for j=1:1:lines quit:linematch  do
	. if parentpid=ps(j,3) set linematch=j
	if 'linematch  do
	. use $p write "Problem finding delay_filter3 20 2 - stopping test",!
	. write "current process id = ",$job,!
	. write "ps -ef output for debugging:",!
	. for j=1:1:lines  write ps(j),!
	. halt

	; save pids for termination in closestatus.csh if still around
	set pfile="pids_test8"
	open pfile:newversion
	use pfile
	write parentpid_" "_ps(linematch,2),!
	close pfile
	close p:timeout=10
	write "PIPE close status = ",$ZCLOSE,!!
	quit

getfield(input,remainder)
	; return first field and save the remaining fields
	set input=$$FUNC^%TRIM(input) ;strip any leading spaces
	set space=$find(input," ")
	set field=input
	if space do
	. set field=$extract(field,1,space-2)
	. set remainder=$extract(input,space-1,500)
	quit field

openpipe(des,commarg)
	; open pipe using des as the handle and commarg as the command value
	new type,comstr
	set type=""_commarg_""
	set comstr=""""_des_""""_":(comm="""_type_""")::""pipe"""
	open @comstr
	quit

getchild(p,ps,linematch,command)
	; save ps output matching "command" in "ps" array and store line number
	; where the parent equals $job in linematch
	; exercise the open pipe device - p
	do testpipe(p,command,.totcom)
	; use a pipe named psout to get lines matching the command
	set psout="psout"
	; Normally we would use "ps -ef" command here but Alpine Linux does not have the same output that other
	; glibc based distros have so specify a custom output that works on both flavors (glibc and Alpine/musl/busybox).
	set comarg="ps -eo user,pid,ppid,args | grep -w "_command_" | grep -v grep"
	do openpipe(psout,comarg)
	use psout
	kill ps
	for i=1:1 read ps(i) quit:$zeof  do
	. set a=ps(i)
	. ; parse the first 3 fields
	. for j=1:1:3 do
	.. set ps(i,j)=$$getfield(a,.a)
	use $p
	; need at least 2 lines for success
	if 3>i use $p write "Problem starting "_totcom_" - stopping test",! halt
	close psout
	use $p
	; find the ps line with parent equal $job - the first line in the first example of ps output in this file
	set lines=i-1
	set linematch=0
	for j=1:1:lines quit:linematch  do
	. if $job=ps(j,3) set linematch=j
	if 'linematch  do
	. use $p write "Problem finding tcsh -c "_totcom_" - stopping test",!
	. write "current process id = ",$job,!
	. write "ps output for debugging:",!
	. zwrite lines,ps
	. halt
	quit

testpipe(p,command,totalcomm)
	; exercise the pipe and output total command name to $p
	new x
	use p
	write "abcdefg",!
	; read parameters passed to delay_filter, delay_filter2 or delay_filter3
	read x
	set totalcomm=command_" "_x
	use $p
	write "pipe command: "_totalcomm,!
	use p
	read x
	use $p
	write x,!
	quit
