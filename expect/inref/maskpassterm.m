;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A helper script for the maskpass_term test. It obtains the list of signals on the current platform
; (as reported by kill -l) and tries each one on a maskpass process, making sure that it survives or
; terminates as expected.
maskpassterm
	new i,j,pipe,pid,pids,line,ln,pos,signals,count,maskpass,maskpassPid,signal,killed,errno

	; Obtain the count of supportable signals.
	set pipe="pipe"
	open pipe:(command="kill -l")::"PIPE"
	use pipe
	for  read line quit:($zeof)!($get(i)>=30)  do
	.	set line=$$FUNC^%TRIM(line)
	.	set:(""'=line) signals($increment(i))=line
	set count=i
	close pipe

	; Go through all signals, trying each on maskpass.
	set maskpassPid=0
	for i=1:1:count do
	.	; If maskpass was killed, start a new instance.
	.	if (0=maskpassPid) do
	.	.	kill line,pids
	.	.	set maskpass=$ztrnlnm("gtm_dist")_"/plugin/gtmcrypt/maskpass"
	.	.	open pipe:(command="$gtm_dist/plugin/gtmcrypt/maskpass")::"PIPE"
	.	.	use pipe
	.	.	read line(pipe)#5  ; Use length of read to wait for maskpass to start before proceeding
	.	.	if line(pipe)'="Enter" use $p zshow "*" ; TODO
	.	.
	.	.	set pid="pid"
	.	.	open pid:(command="$psuser")::"PIPE"
	.	.	use pid
	.	.	read line(0)     ; wait to read the PS headers before proceeding
	.	.	; Target the maskpass spawned by this process, note the interstitial process for the PIPE device
	.	.	;e1020505  6583  4093  0 14:53 pts/12   00:00:00 /usr/library/V982/dbg/mumps -run maskpassterm"
	.	.	;e1020505 12301  6583  0 14:57 pts/12   00:00:00 tcsh -c $gtm_dist/plugin/gtmcrypt/maskpass"
	.	.	;e1020505 12509 12301  0 14:57 pts/12   00:00:00 /usr/library/V982/dbg/plugin/gtmcrypt/maskpass"
	.	.	for ln=1:1  do  quit:(0'=maskpassPid)!(""=line(ln))!$zeof
	.	.	.	read line(ln)
	.	.	.	; Line does not contain "gtmcrypt/maskpass" in it
	.	.	.	quit:line(ln)'["gtmcrypt/maskpass"
	.	.	.	set line=$$^%MPIECE(line(ln))
	.	.	.	set pids(+$piece(line," ",3))=+$piece(line," ",2)
	.	.	.	; No match to M routine as parent
	.	.	.	quit:'$data(pids($job))
	.	.	.	; No match to tcsh command as parent
	.	.	.	quit:'$data(pids(pids($job)))
	.	.	.	set maskpassPid=pids(pids($job))
	.	.	close pid
	.	.	use $principal
	.
	.	; Something went wrong with pid acquisition, so prevent any damage to the system.
	.	if (maskpassPid<2) do
	.	.	write "TEST-E-FAIL, Invalid maskpass pid ("_maskpassPid_") for ",$job,!
	.	.	zwrite line
	.	.	zhalt 1
	.
	.	set signal=signals(i)
	.
	.	; These signals stop rather than kill the process.
	.	quit:("STOP"=line)!("TTIN"=line)!("TTOU"=line)
	.
	.	; If maskpass suddenly died, then it must have been due to a prior signal which we did not expect to be fatal.
	.	set errno=$zsigproc(maskpassPid,i)
	.	if (errno) do
	.	.	write "TEST-E-FAIL, Failed (with errno "_errno_") to send signal "_i_" ("_signal_") to maskpass (pid "_maskpassPid_"); "
	.	.	write "it must have died due to one of the earlier signals.",!
	.	.	zwrite line
	.	.	zhalt 1
	.
	.	; Ensure that maskpass terminates in 30 seconds on any of the fatal signals.
	.	set killed=0
	.	if ("INT"=signal)!("TERM"=signal)!("SEGV"=signal)!("ABRT"=signal)!("BUS"=signal)!("FPE"=signal)!("TRAP"=signal)!("KILL"=signal) do
	.	.  	; Hang loop for 300 seconds (5 min)
	.	.	for j=1:1:1500 set:($zsigproc(maskpassPid,0)) killed=1 quit:killed  hang 0.2
	.	.	if ('killed) do
	.	.	.	write "TEST-E-FAIL, Failed to terminate maskpass (pid "_maskpassPid_") with signal "_i_" ("_signal_").",!
	.	.	.	zhalt 1
	.	.	else  do
	.	.	.	close pipe
	.	.	.	; Certain signals produce cores; remove them.
	.	.	.	zsystem "rm -rf core* >&! /dev/null"
	.	.	.	set maskpassPid=0
	.	.	close pipe
	if (0'=maskpassPid) do
	.	if $zsigproc(maskpassPid,9) quit
	.	set killed=0
	.	; Hang loop for 300 seconds (5 min)
	.	for j=1:1:1500 set:($zsigproc(maskpassPid,0)) killed=1 quit:killed  hang 0.2
	.	if ('killed) do
	.	.	write "TEST-E-FAIL, Failed to terminate maskpass (pid "_maskpassPid_") with signal 9 (KILL).",!
	.	.	zhalt 1
	close pipe
	write "TEST-I-SUCCESS, Test succeeded.",!
	quit
