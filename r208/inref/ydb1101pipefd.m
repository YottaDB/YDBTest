;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
ydb1101pipefd	; Called by r208/u_inref/fuzz_asserts11-ydb1101.csh. Each stageN label is a stage. A stage opens files
	; until an OPEN fails, and then runs its command. An error is reported as "error=<mnemonic>",
	; "text=<text>" and "errno=<mnemonic>".
	quit
stage1	; JOB with no file descriptor free
	set $etrap="do err^ydb1101pipefd"
	do usefds
	do job
	write "end",!
	quit
job	; the JOB in a frame of its own, so that the stage goes on after the error
	job child^ydb1101pipefd
	quit
child	; the JOB command fails before a child process starts
	quit
stage2	; OPEN of a PIPE device with no file descriptor free
	set $etrap="do err^ydb1101pipefd"
	do usefds
	do pipe
	write "end",!
	quit
pipe	; the OPEN in a frame of its own, so that the stage goes on after the error
	open "pipedev":(command="true")::"pipe"
	quit
usefds	; open files until an OPEN fails, and report the errno of that failure
	new $etrap,i
	set $etrap="do fdsdone^ydb1101pipefd"
	for i=1:1:2000 open "fdfile"_i:newversion
	write "usefds did not run out of file descriptors",!
	quit
fdsdone	; the error that ended the loop in usefds
	use $principal
	write "usefds errno=",$piece($piece($zstatus,",",5),"-",3),!
	set $ecode=""
	quit
err	; report the mnemonic of the error and go on with the next line of the stage
	use $principal
	write "error=",$piece($piece($zstatus,",",3),"-",3),!
	write "text=",$extract($piece($zstatus,",",6),2,$length($zstatus)),!
	write "errno=",$piece($piece($zstatus,",",7),"-",3),!
	set $ecode=""
	quit
