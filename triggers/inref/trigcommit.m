;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
; Test that TCOMMIT inside of trigger (to balance TSTART outside of trigger) errors out at TCOMMIT time
trigcommit
	do setup
	do ^echoline
	write "TCOMMIT inside trigger issues YDB-E-TRIGTCOMMIT",!
	do ^echoline
	set $etrap="do etr^trigcommit"
	tstart ():serial
	set x=$increment(^CIF(1))
	tcommit:$tlevel
	quit
etr	;
	if $zstatus["TRIGTCOMMIT" write "PASS",! halt
	write "$zlevel=",$zlevel," : $ztlevel=",$ztlevel," : $ecode=",$ecode," : ZSTATUS=",$zstatus,!
	if $tlevel  tcommit
	zwr ^CIF
	set $ecode=""
	quit

trig1
	set x=$INCR(^dummy(acn))
	if acn<100  do
	.	tcommit
	.	write "TEST-F-FAIL This code should never be reached",!
	quit

setup
	do text^dollarztrigger("tfile^trigcommit","trigcommit.trg")
	do file^dollarztrigger("trigcommit.trg",1)
	quit

tfile
	;+^CIF(acn=:) -commands=SET -xecute="do trig1^trigcommit"
