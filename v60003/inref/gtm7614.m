;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2013-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
critholder
	lock ready				; gate to hold critwaiter at the right place
	set $zinterrupt="halt"
	set file="pidholder.txt"
	open file:(newversion:exception="write $zstatus zhalt 1")
	use file
	write $job,!
	close file
	set ^b=$job 				; ^b deliberately chosen to open BREG (we get assert otherwise)
	set ^letsgo=1 ; tell the other process BREG is now open by using a global from DEFAULT region to avoid crit conflicts
	for i=1:1:240 quit:$data(^c)  hang 0.5	; wait for critwaiter to open CREG
	if '$data(^c) write "Did not see critwaiter start",! quit
	if $view("PROBECRIT","BREG")		; establish & hold crit - no global set/kill/gets beyond this point to avoid asserts
	lock -ready				; signal crit held state established using a LOCK in the DEFAULT region
	hang 300				; we should receive an interrupt from gtm7614.csh within 5 minutes
	write "Did not receive interrupt within 5 minutes.",!
	quit

critwaiter
	set file="pidwaiter.txt"
	open file:(newversion:exception="write $zstatus zhalt 1")
	use file
	write $job,!
	close file
	set ^c=$job				; ^c deliberately chosen to open CREG (we get assert otherwise)
	for i=1:1:240 quit:$data(^letsgo)  hang 0.5	; wait on a global in the DEFAULT region for critwaiter to open BREG
	if '$data(^letsgo) write "Did not see critholder start",! quit
	lock ready:240	; wait for critholder to hold crit on BREG by using a global from DEFAULT region to avoid crit conflicts
	else  write "Did not see critholder signal it has established its crit hold",! quit
	if $view("PROBECRIT","CREG")		; establish & hold crit - no global set/kill/gets beyond this point to avoid asserts
	if $view("PROBECRIT","BREG")		; this deadlocking crit should cause a MUTEXRELEASED and that releases CREG's crit
	quit
