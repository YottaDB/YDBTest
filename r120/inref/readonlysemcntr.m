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

	; Used to test that multiple processes accessing the help database work fine with ftok semaphore counter overflow
readonlysemcntr;
	set jnolock=1	; since this is a read_only db, M LOCK commands do not work (they need shared memory)
	do ^job("child^readonlysemcntr",8,"""""")
	quit

child	;
	set x=$get(^x)
	hang 2*$random(2)	; randomly sleep to induce different orders of child process rundowns
	quit
