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
intr1269	; Helper routine for the intrpt_readline-ydb1269 subtest
	; Reaches the direct mode prompt with a MUPIP INTRPT still pending. The ZSYSTEM and the BREAK below
	; are deliberately on the same M line: an interrupt that arrives while the ZSYSTEM child runs is not
	; acted on until the next check for it, and with no line boundary between the two commands that check
	; is the one inside readline_read_mval(). The process therefore enters direct mode with the event
	; pending and with libreadline never yet initialized, which is the state that caused the YDB#1269 SIGSEGV.
	kill ^intr1269
	set $zinterrupt="set ^intr1269=$get(^intr1269,0)+1"
	write "DMPID=",$job,!
	zsystem "sleep 3" break
	write "AFTERBREAK",!
	quit
