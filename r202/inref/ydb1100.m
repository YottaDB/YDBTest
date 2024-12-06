;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Below test program is based off https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2119#note_2230857364

ydb110	;
	write "# Parent process jobs off a child process and communicates with child through a socket",!
	write "# The socket is opened with NODELIM",!
	write "# Child process does 256 WRITE commands each of which write small pieces of text",!
	write "# Before the YDB#1100 fixes, all 256 write command outputs would be read by ONE untimed READ command",!
	write "# (as it would wait for all data to be available before terminating the READ command).",!
	write "# Whereas after the YDB#1100 fixes, an untimed READ with NODELIM returns whenever SOME data is available",!
	write "# We therefore expect the parent process to read the 256 WRITE command data in MULTIPLE untimed READ commands",!
	job child	; job child which will have a connecting TCP socket, parent will have a listening TCP socket
	set s="socket"
	open s:(listen=$ztrnlnm("portno")_":TCP":attach="handle1"):15:"socket"
	use s:(nodelim)
	write /wait
	set expected="" for i=1:1:256 set expected=expected_"Piece "_i_"; "
	set actual="" for  read cmdop($incr(cmdop)) set actual=actual_cmdop(cmdop) quit:$device
	close s
	if actual'=expected write "TEST-E-FAIL : Expected = ",expected," : Actual = ",actual,!
	else  write "PASS: Parent read all 256 pieces of data from child exactly as expected",!
	set minreads=2
	if cmdop<minreads write "TEST-E-FAIL : Parent used ",cmdop," READ commands. Expecting at least ",minreads," READ commands",!
	else  write "PASS: Parent used at least ",minreads," READ commands (as expected)",!
	do ^waitforproctodie($zjob)	; wait for jobbed/child process to terminate before returning to caller
	quit
child	;
	set s="socket"
	open s:(CONNECT="[127.0.0.1]:"_$ztrnlnm("portno")_":TCP":ioerror="trap")::"SOCKET"
	use s
	for i=1:1:256 write "Piece "_i_"; "
	quit
