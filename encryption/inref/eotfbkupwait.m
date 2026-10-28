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

; Used by the encryption/eotf_backup subtest, which starts it in the background before it starts an online MUPIP BACKUP
; of region DEFAULT. Creates the file eotfbkupwait.ready once it is polling, then waits until the backup has started
; (node_local.nbb is no longer BACKUP_NOT_IN_PROGRESS) or has terminated (its pid, read from pid.out, is gone).
; Prints "STARTED" or "DONE" respectively, or "TIMEOUT" after 300 seconds, then creates the file eotfbkupwait.done.
eotfbkupwait
	new nbb,pid,result,start
	set nbb=$$^%PEEKBYNAME("node_local.nbb","DEFAULT")	; opens the region before eotfbkupwait.ready is created
	open "eotfbkupwait.ready":newversion close "eotfbkupwait.ready"
	set start=$zut,pid=0
	for  do  quit:$data(result)
	.	if "9223372036854775807"'=$$^%PEEKBYNAME("node_local.nbb","DEFAULT") set result="STARTED" quit
	.	if 'pid,""'=$zsearch("pid.out",-1) open "pid.out":readonly use "pid.out" read pid close "pid.out" set pid=+pid
	.	if pid,'$zgetjpi(pid,"isprocalive") set result="DONE" quit
	.	if 300000000<($zut-start) set result="TIMEOUT" quit
	.	hang 0.001
	write result,!
	open "eotfbkupwait.done":newversion close "eotfbkupwait.done"
	quit
