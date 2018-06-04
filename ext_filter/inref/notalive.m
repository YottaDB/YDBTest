;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

notalive ; External filter, bad filter that exits as soon as it reads something
	; intended to get FILTERNOTALIVE error
	use $principal:(nowrap)
	; Randomly introduce a sleep here before reading/consuming data that the source server wrote to the pipe.
	; This will ensure that the source server is doing read() after having filled the write side of the pipe.
	; Having the sleep time more than the source server's heartbeat timer of 15 seconds will ensure the
	; global variable "errno" is set to EINTR and the halt done below will ensure the read() done in the
	; source server will return 0 with errno set to EINTR which exposes the following issue
	; #264 : Source server spin loops (instead of issuing FILTERNOTALIVE error) when external filter program terminates
	; Random choice is to ensure no-sleep test path (which was how this test ran before #264 fix) also works fine in the code.
	hang:$random(2) 20
	read extrRec
	halt
	quit

set	;
	; Write a HUGE transaction whose journal extract representation is more than 64K
	; the maximum size of a pipe in Linux. That way the source server will get an EAGAIN
	; while trying to write() to the pipe and switch to doing read() calls which exposes #264
	; The journal extract representation of each line is approximately 32 bytes. And so
	; having 32K (2**15) of those ensures the total length is greater than 64K for sure
	; and yet less than 1Mb the maximum string length supposed by YottaDB (going more than
	; 1Mb will cause a MAXSTRLEN error in extfilternotalive (the external filter program).
	; To enhance this test case further, randomly vary the HUGENess of this transaction.
	;
	set n=2**$random(16)
	tstart ():serial
	for i=1:1:n set ^a=i
	tcommit
	quit
