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
; YDB#1231 : MUPIP INTEG waited a minute for kill_in_prog to clear, and then a second minute, before
; issuing MUKILLIP, and MUPIP FREEZE and MUPIP BACKUP waited a minute. This routine produces the state
; they were waiting on: a KILL whose process is gone and which therefore left kill_in_prog set for good.
; "setupc" and "hold" produce the opposite: KILLs whose processes are alive, more of them than the
; 8 slots of the shared memory list of processes doing a KILL can record.
;
; "setup" fills enough of the database that "abandon" spends its second phase freeing blocks across
; several bitmaps. "abandon" writes its own process id where the caller can read it and then starts
; the KILL; the caller terminates it with a signal the process cannot handle while it sits in that
; second phase, which the WBTEST_ABANDONEDKILL white box test case holds it in.
;
setup	; set enough globals that killing them frees blocks in more than one bitmap
	for i=1:1:10 do
	. for j=1:1:10 do
	. . for k=1:1:10 do
	. . . set ^a(i,j,k)=$justify("a",200),^b(i,j,k)=$justify("b",200)
	write "setup done",!
	quit
	;
abandon	; report this process id, then KILL what "setup" created
	set file="job.txt"
	open file use file write $JOB,! close file
	use $principal
	for i=1:1:10 do
	. for j=1:1:10 do
	. . kill ^a(i,j),^b(i,j)
	write "killing done",!
	quit
	;
setupc	; give each of 9 "hold" processes a subtree of its own, large enough that its KILL has a phase II
	for n=1:1:9 do
	. for i=1:1:10 do
	. . for j=1:1:10 do
	. . . set ^c(n,i,j)=$justify("c",200)
	write "setupc done",!
	quit
	;
hold	; report this process id in hold<n>.pid, then KILL subtree <n> of ^c, where <n> is the command line
	new n,file
	set n=+$zcmdline,file="hold"_n_".pid"
	open file use file write $JOB,! close file
	use $principal
	kill ^c(n)
	write "kill done",!
	quit
	;
offset	; write the offset of kip_set_by_dse in the file header
	new gtmtypes,gtmtypfldindx,gtmsdver,gtmsdtyp
	do Init^GTMDefinedTypesInit
	write gtmtypes("sgmnt_data",gtmtypfldindx("sgmnt_data","kip_set_by_dse"),"off"),!
	quit
	;
peek	; write kip_set_by_dse of region DEFAULT, as the current release reads it
	write $$^%PEEKBYNAME("sgmnt_data.kip_set_by_dse","DEFAULT"),!
	quit
