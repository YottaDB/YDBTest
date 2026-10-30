;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
; Helper routine for the r208/trestart_dm_uncounted-ydb1338 subtest
;
ztrap	; Divide by zero with $ZTRAP set to BREAK, so Direct Mode runs in the $ZTRAP frame (not a counted frame)
	set $ztrap="break"
	write 1/0
	quit
	;
ztrapo	; TSTART in a routine, then a divide by zero with $ZTRAP set to BREAK, so a TSTART at the Direct Mode prompt
	; is an inner transaction level whose restart frame is the $ZTRAP frame (not a counted frame)
	set $ztrap="break"
	tstart ()
	write 1/0
	quit
	;
zbrk	; BREAK in a ZBREAK action, so Direct Mode runs in the ZBREAK action frame (not a counted frame)
	zbreak zbrk1^ydb1338:"break"
	do zbrk1
	quit
zbrk1	quit
	;
zstp	; BREAK in a ZSTEP action, so Direct Mode runs in the ZSTEP action frame (not a counted frame)
	set $zstep="break"
	zstep into
	quit
	;
devex	; BREAK in a device EXCEPTION action, so Direct Mode runs in the EXCEPTION action frame (not a counted frame)
	new f,x
	set f="ydb1338ex.txt"
	open f:newversion use f write "x",! close f
	open f:(readonly:exception="use $principal break")
	use f read x read x
	quit
	;
brk	; BREAK in a routine, so Direct Mode runs on top of this counted frame. A TRESTART in Direct Mode resumes this
	; routine right after the BREAK.
	set d=1
	break
	write $select((1=$trestart)&(1=$get(d)):"PASS",1:"WRONG")," : the transaction restarted once and d was restored"
	write " ($TRESTART=",$trestart," d=",$get(d),")",!
	tcommit
	write $select(0=$tlevel:"PASS",1:"WRONG")," : $TLEVEL=",$tlevel," after TCOMMIT",!
	quit
	;
rtn	; TSTART, argumentless NEW and TRESTART in a routine (no Direct Mode)
	set d=1
	tstart (d)
	write:$trestart $select(1=$get(d):"PASS",1:"WRONG")," : d=",$get(d)," at the start of retry ",$trestart,!
	new
	set d=2
	if $trestart<2 trestart
	write $select(2=$trestart:"PASS",1:"WRONG")," : $TRESTART=",$trestart,!
	tcommit
	write $select(0=$tlevel:"PASS",1:"WRONG")," : $TLEVEL=",$tlevel," after TCOMMIT",!
	quit
	;
newdo	; Argumentless NEW in a routine called by a DO, then TRESTART while that routine is still active
	new
	set d=3
	trestart:$trestart<1
	quit
