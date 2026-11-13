;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
negtmo1402	; Helper routines for the r208/negative_timeout-ydb1402 subtest
	quit
	;
start	; JOB a process that holds LOCK l and ZALLOCATE l until stop^negtmo1402 asks it to exit
	new i
	set ^stop=0,^ready=0
	job hold^negtmo1402
	set ^pid=$zjob
	for i=1:1:1200 quit:^ready  hang 0.05
	if ^ready write "PASS : the holding process has LOCK l and ZALLOCATE l",!
	else  write "FAIL : the holding process did not get LOCK l and ZALLOCATE l within 60 seconds",!
	quit
	;
hold	; Hold LOCK l and ZALLOCATE l until ^stop is set
	lock +l
	zallocate l
	set ^ready=1
	for  quit:^stop  hang 0.05
	quit
	;
stop	; Ask the holding process to exit, and wait for it to do so
	new i
	set ^stop=1
	for i=1:1:1200 quit:'$zgetjpi(^pid,"ISPROCALIVE")  hang 0.05
	if $zgetjpi(^pid,"ISPROCALIVE") write "FAIL : the holding process did not exit within 60 seconds",!
	else  write "PASS : the holding process exited",!
	quit
	;
try	; Run one command with a negative timeout. $ZCMDLINE is the command and the timeout, for example "LOCK -1".
	do attempt($piece($zcmdline," ",1),$piece($zcmdline," ",2))
	quit
	;
attempt(cmd,timeout)	; Run cmd with timeout, then report $TEST and whether cmd returned within 5 seconds
	; LOCK and ZALLOCATE wait for the name that hold^negtmo1402 holds. READ waits for input from a PIPE device
	; whose command, cat, writes nothing until it reads input, which this process never sends. Each command saves
	; $TEST and the time on its own line, before another IF changes $TEST.
	new elapsed,p,start,test,x
	if "LOCK"=cmd set start=$zut lock +l:timeout set test=$test,elapsed=$zut-start
	if "ZALLOCATE"=cmd set start=$zut zallocate l:timeout set test=$test,elapsed=$zut-start
	if "READ"=cmd do
	. set p="catpipe"
	. open p:(command="cat")::"pipe"
	. use p
	. set start=$zut read x:timeout set test=$test,elapsed=$zut-start
	. use $principal
	. close p
	write cmd," with timeout ",timeout," : $TEST=",test
	write $select(elapsed<5000000:", returned within 5 seconds",1:", returned after "_(elapsed\1000)_" milliseconds"),!
	quit
