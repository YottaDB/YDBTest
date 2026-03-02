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

START
	write "# Starting ydb918.m to test the new intrinsic special variable $ZYJOBPARENT",!
	write "# First write out $ZYJOBPARENT to test its value when JOBPARENT does not exist",!
	write "# By convention we expect the result 0",!
	write $ZYJO,!
	write "# Now output this parent's PID in a file",!
	OPEN "parentPID.txt":(NEWVERSION)
	USE "parentPID.txt"
	WRITE $JOB
	CLOSE "parentPID.txt"
	USE $P
	write "# Next start a jobed process to check its value",!
	JOB JOBLABEL
	do ^waitforproctodie($zjob)
	QUIT
JOBLABEL
	OPEN "ChildZYJOBPARENT.txt":(NEWVERSION)
	USE "ChildZYJOBPARENT.txt"
	write $ZYJOBPARENT
	CLOSE "ChildZYJOBPARENT.txt"
	OPEN "childPID.txt":(NEWVERSION)
	USE "childPID.txt"
	write $JOB
	CLOSE "childPID.txt"
	JOB JOBSUBLABEL
	do ^waitforproctodie($zjob)
	QUIT
JOBSUBLABEL
	; we also try going one level deeper, just to make sure
	; that $ZYJOBPARENT will still work for a jobed process
	OPEN "childChildZYJOBPARENT.txt":(NEWVERSION)
	USE "childChildZYJOBPARENT.txt"
	write $ZYJOBPARENT
	CLOSE "childChildZYJOBPARENT.txt"
	QUIT
