;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
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
jobfail;
	view "JOBPID":1
	job label^jobfail:(output="op":error="err")
	; $zroutines would have been set to "jobfail.so" by caller to test that stdout/stderr are not modified
	; by middle process created during JOB command execution.
	; But we need to wait for jobbed off process to finish before returning (to avoid TEST-E-LSOF errors from test framework)
	; so reset $zroutines to what it should have been (derive it from the "ydb_routines" env var) and wait for job to die.
	set $zroutines=$ztrnlnm("ydb_routines")
	do ^waitforproctodie($zjob,300)
	quit
label
	quit
