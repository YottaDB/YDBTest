;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-9230 - NOISOLATION for non-TP works like NOISOLATION for TP transactions. This test was originally taken from
; r124/inref/ydb353.m and modified to eliminate TP usage.
;
gtm9230
	set $etrap="write $zstatus,!!! zshow ""*"" zhalt 1"
	kill ^x,^testPids		  ; Initialize
	set ^cmdline=$zcmdline,^max=5000,^njobs=5
	write !,"Starting ",^cmdline," run",!
	; Initialize nodes now so don't have restart collisions doing it (which would have a different restart type)
	for i=1:1:^njobs set ^x(i)=0
	; Gather starting specs so we can tell how many non-TP restarts happened during our run
	set nr0Start=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_0","DEFAULT"))
	set nr1Start=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_1","DEFAULT"))
	set nr2Start=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_2","DEFAULT"))
	set nr3Start=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_3","DEFAULT"))
	;
	do ^job("child^"_$text(+0),^njobs,"""""")
	;
	; Collect the non-TP restart count GVSTATS (NR0-NR3) and print them
	set nr0End=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_0","DEFAULT"))
	set nr1End=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_1","DEFAULT"))
	set nr2End=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_2","DEFAULT"))
	set nr3End=$$FUNC^%HD($$^%PEEKBYNAME("node_local.gvstats_rec.n_nontp_retries_3","DEFAULT"))
	write !,^cmdline," non-TP restart counters: NR0: ",nr0End-nr0Start,"   NR1: ",nr1End-nr1Start,"   NR2: ",nr2End-nr2Start,"   NR3: ",nr3End-nr3Start,!!
	quit

; Child routine - run ^njobs of these to create datablock collisions (all ^njobs processes are updating counters
; in the same datablock).
child
	new i,val
	set ^testPids($job)=1		; This PID is part of our test
	set $etrap="write $zstatus,!!! zshow ""*"" zhalt 1"
	if ^cmdline="NOISOLATION" view "NOISOLATION":"+^x"
	for i=1:1:^max set ^x(jobindex)=$increment(val)
	quit

; Routine to drive the validations of a set of syslogs for the [NO]ISOLATION runs. Verify the type is correct.
DriveSyslogValidation
	write "# ISOLATION validation (non-TP):",!
	do validateRestartMessages("syslog_ISOLATION.txt",13)
	write !,"# NOISOLATION validation (non-TP):",!
	do validateRestartMessages("syslog_NOISOLATION.txt",14)
	quit

; Routine to validate a given file that the NONTPRESTART messages in it are all of the given type and if they aren't, check for
; some conditions that allow us to not care about the mismatch.
validateRestartMessages(fn,type)
	new rectype,line,x,code,glbl,pid,recidx
	open fn:readonly
	for recidx=1:1  use fn read line quit:$zeof  do
	. quit:(line'["YDB-I-NONTPRESTART")				; Only process the expected information messages about restarts
	. set x=$zpiece(line," type: ",2)				; Isolate 'type: nn,'
	. set rectype=$zpiece(x,",",1)
	. if rectype'=type do
	. . set x=$zpiece(line,"[",2)					; Isolate PID that put out the message
	. . set pid=$zpiece(x,"]",1)
	. . if '($get(^testPid(pid),0)) do logBypass(.line) quit	; Bypass subprocesses not part of our test
	. . set x=$zpiece(line," code: ",2)				; Isolate 'code: x[xxx]'
	. . set code=$zpiece(x,";",1)
	. . if ("L"'=$zextract(code,$zlength(code))) do logBypass(.line) quit	; Bypass if this restart is not code 'L'
	. . set x=$zpiece(line," glbl: ",2)			  	; Isolate 'glbl: ^x(...)'
	. . set glbl=$zpiece(x,";",1)
	. . if ("^x("'=$zextract(glbl,1,3)) do logBypass(.line) quit	; Bypass if this restart is not for global '^x'
	. . use $p
	. . write "Unexpected message type. Expected ",type," but found ",rectype," in line ",recidx," in file ", fn,!
	. . zwrite line
	. . zhalt 1
	close fn
	use $p
	write "File ",fn," validated as having only type ",type," restarts",!
	quit

; Routine to log a bypassed record in a special debug/error file for debugging purposes.
logBypass(record)
	new file
	set file="bypassedRecordLog.txt"
	open file:append
	use file
	write record,!
	close file
	quit

