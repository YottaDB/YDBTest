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

ydb1205 ; Test the current process signal mask to determine whether SIGUSR1 is blocked
	write "YottaDB version "_$zyrelease,!
	; Extract signal 10 [SIGUSR1] (3rd to last hex digit)
	set cmd="grep '^SigBlk:' /proc/"_$job_"/status | awk '{print substr($2, length($2)-2, 1)}'"
	open "pipe":(command=cmd:readonly)::"pipe"
	use "pipe" read hex close "pipe" use $principal
	set dec=$zconvert(hex,"hex","dec")
	set bin=$select(dec\8:1,1:0)
	set dec=dec#8
	set bin=bin_$select(dec\4:1,1:0)
	set dec=dec#4
	set bin=bin_$select(dec\2:1,1:0)
	set dec=dec#2
	set bin=bin_$select(dec\1:1,1:0)
	; Extract signal 10 [SIGUSR1] binary digit (2nd to last binary digit)
	write "SIGUSR1 Blocked: "_$extract(bin,3),!
	quit
