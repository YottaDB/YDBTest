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
; Helper routines of the sleepstats_nonzero-gtm10554 subtest. See that subtest for the overall scheme.
gtm10554	;
	quit

holderjnl	; Run with white-box test case 142 (WBTEST_JNL_WRITE_HANG) enabled.
	; Each TCOMMIT hardens the journal file after it releases crit. The 500th write to the journal file sleeps
	; (for the number of seconds in gtm_white_box_test_case_count) while this process owns the journal file.
	; The loop runs until the subtest stops this process. ^progress lets "waithang" see whether the loop is running.
	new i
	do writepid
	for i=1:1 tstart ():serial  set ^holder(i#20000)=$justify(i,200),^progress=i  tcommit
	quit

holderdb	; Run with white-box test case 143 (WBTEST_DB_WRITE_HANG) enabled.
	; The updates dirty many global buffers, which this process then writes to the database file from the flush
	; timer. The 75th write to the database file sleeps (for the number of seconds in
	; gtm_white_box_test_case_count) while this process owns the global buffer being written.
	; The loop runs until the subtest stops this process. ^progress lets "waithang" see whether the loop is running.
	new i
	do writepid
	for i=1:1 set ^holder(i#20000)=$justify(i,200),^progress=i
	quit

writepid	;
	new file
	set file="holder.pid"
	open file:newversion  use file  write $job,!  close file
	quit

waithang	; Wait for the holder process to stop making progress, which means that process is in the white-box sleep.
	; The holder sets ^progress in every iteration with no pause in between, so two readings of ^progress
	; that are 1 second apart and the same mean that the holder is not running.
	new prev,cur,i
	set prev=-1
	for i=1:1:60  set cur=+$get(^progress)  quit:(cur>0)&(cur=prev)  set prev=cur  hang 1
	write $select(i<60:"# Holder process is in the white-box sleep",1:"TEST-E-FAIL : holder process did not stop"),!
	quit

jns	; Waiter : a TCOMMIT hardens the journal file after it releases crit, so the wait is outside crit
	tstart ():serial  set ^waiter($job)=1  tcommit
	do check("JNS",$$private("JNS"))
	quit

jcs	; Waiter : VIEW "JNLFLUSH" writes the journal buffer to the journal file while it holds crit
	set ^waiter($job)=1
	view "JNLFLUSH"
	do check("JCS",$$private("JCS"))
	quit

wpcs	; Waiter : update every node that the holder has set, hence every block that the holder could be writing
	new i
	for i=0:1:19999 set ^holder(i)=$justify(i,199)
	do check("WPCS",$$private("WPCS"))
	quit

check(name,value)	; a value of 1000 or more means that this process slept for at least a second
	write name," is 1000 or more : ",$select(value>=1000:"PASS",1:"FAIL ["_value_"]"),!
	quit

private(name)	; return statistic "name" of this process for region DEFAULT (from ZSHOW "G")
	new line,i,ret
	zshow "G":line
	set ret="",i=""
	for  set i=$order(line("G",i)) quit:i=""  if line("G",i)[",REG:DEFAULT," set ret=$piece($piece(line("G",i),","_name_":",2),",",1)
	quit ret

shared(name)	; write statistic "name" of region DEFAULT that all processes share (from $VIEW("GVSTATS"))
	write $piece($piece($view("GVSTATS","DEFAULT"),","_name_":",2),",",1),!
	quit
