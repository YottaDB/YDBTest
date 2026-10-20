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
tpna1090	; Helper routines for the r208/tpnotacid_dmode-ydb1090 subtest
	quit
	;
pastlimit	; Restart a transaction until it passes the TPNOTACID retry limit (used by stages 1 to 3)
	; Inside a transaction, ZSYSTEM checks for TPNOTACID on every restart. At the third restart, the check logs a
	; warning to the syslog, and once there have been more than 16 restarts, it raises the TPNOTACID error. With the
	; default $ZTRAP="B", the error takes the process to direct mode, still inside the transaction.
	tstart ():serial
	zsystem "true" trestart
	tcommit
	quit
	;
job	; Stage 1: JOB a process that passes the limit, with /dev/null as its input
	; The wait is bounded, so that if direct mode looped again, the stage would fail instead of running until
	; the process filled the disk. A process still running is stopped with MUPIP STOP, sent up to three times
	; 10 seconds apart, since three within a minute make it exit even if it is deferring the stop.
	new alive,i,pid
	job pastlimit^tpna1090:(output="stage1.mjo":error="stage1.mje")
	set pid=$zjob
	set alive=$$xwaitforproctodie^waitforproctodie(pid,60)
	if ""'=alive do  quit
	. write "TEST-E-JOBALIVE, the JOBbed process is still running after 60 seconds, so it is presumably looping",!
	. for i=1:1:3 zsystem "$gtm_dist/mupip stop "_pid  set alive=$$xwaitforproctodie^waitforproctodie(pid,10)  quit:""=alive
	. if ""'=alive write "TEST-E-JOBALIVE, the JOBbed process is still running after three MUPIP STOPs",!
	write "# The JOBbed process ended on its own",!
	quit
	;
ztloop	; Stage 4: a code-form $ZTRAP retries the failing line, which raises the TPNOTACID error again each time
	new cnt
	set cnt=0
	set $ztrap="set cnt=cnt+1 if 20=cnt write ""# The $ZTRAP code ran "",cnt,"" times"",! trollback  halt"
	tstart ():serial
	zsystem "true" trestart
	tcommit
	quit
	;
twotp	; Stage 4: two transactions in turn pass the limit, and $ETRAP rolls each one back
	new i
	for i=1:1:2 do onetp(i)
	quit
	;
onetp(i)	;
	new $etrap
	; Only the error's mnemonic is written: a full %YDB-E- message in this process's output would be caught by the
	; test framework's error scan
	set $etrap="write ""# Transaction "",i,"" got "",$piece($piece($zstatus,"","",3),""-"",3),! trollback  set $ecode="""""
	tstart ():serial
	zsystem "true" trestart
	tcommit
	quit
