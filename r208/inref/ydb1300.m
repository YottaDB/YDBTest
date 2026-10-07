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
;
; YDB#1300 : processes used by r208/enospc_mupip_stop-ydb1300. The stage name is passed as the command line.
;
ydb1300	;
	quit

tp	; Two TP updates. The first one starts the flush timer that pops during the second one.
	do savepid
	tstart  set ^x=1  tcommit
	tstart  set ^y=1  tcommit
	hang 300
	quit

crit	; Dirty many buffers so some are still waiting to be written when the TP commit below is in phase 1
	do savepid
	new i
	for i=1:1:2000 set ^z(i)=$justify(i,200)
	tstart  set ^x=1  tcommit
	hang 300
	quit

b	; Update the globals that the stopped process updated
	set ^x=2,^y=2,^z(1)=2
	write "B updated ^x, ^y and ^z(1)",!
	quit

savepid	; Write $JOB to <stage>.pid so the test can MUPIP STOP this process
	new file
	set file=$zcmdline_".pid"
	open file:newversion
	use file
	write $job,!
	close file
	quit
