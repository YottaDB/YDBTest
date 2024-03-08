;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
; All rights reserved.
;
;	This source code contains the intellectual property
;	of its copyright holder(s), and is made available
;	under a license.  If you do not know the terms of
;	the license, please stop and do not read further.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mallocLimit
	set debug=0   ; turn on memory usage indicator in output
	set si=0   ; global nuber of strings allocated
	set minimum=2500000   ; expected malloc limit minimum
	write "# Filling memory to limit until warning trap occurs",!
	set $zmalloclim=1    ; lowest positive integer means choose the minimum possible
	if $zmalloclim<minimum write "Not enough memory to fully test mallocLimit",! halt
	if $zmalloclim>minimum write "ZMALLOCLIM minimum is not ",minimum," as expected",! halt
	set $etrap="goto memtrap1"
	do allocate(minimum)
	write "# Fail: didn't trap malloc-limit infringement when it should have",!
	quit

;;;; Subroutines

allocate(size)
	new chunksize,i
    set chunksize=1000000
	for i=1:1:size/chunksize set si=si+1,strings(si)=$justify(si,chunksize)
	set si=si+1,strings(si)=$justify(si,chunksize)
	quit


;;;; Traps

memtrap1
	write "#  Successfully trapped malloc-limit infringement with $ECODE="""_$ecode,"""",!
	if debug write "debug: si=",si,!
	set $ecode=""
	write "# Re-running with higher limit of ",minimum*2,!
	set $zmalloclim=minimum*2
	if $zmalloclim<(minimum*2) write "Not able to set ZMALLOCLIM to ",minimum*2," is there enough OS memory?",! halt
	if $zmalloclim>(minimum*2) write "M set ZMALLOCLIM to ",$zmalloclim," instead of ",minimum*2,! halt
	set $etrap="goto memtrap2"
	do allocate(minimum)   ; allocate another half again
	write "# Fail: didn't trap malloc-limit infringement when it should have",!
	halt

memtrap2
	write "#  Successfully trapped malloc-limit infringement with $ECODE=""",$ecode,""" even after raising the limit",!
	if debug write "debug: si=",si,!
	;halt   ; because I can't get the following memory error to in a reasonable time-frame; 'limit [v]memoryuse' doesn't help.
	write "# Now trying to create fatal memory error by exceeding the limit again without increasing it",!
	set $etrap="goto memtrap3"
	do allocate(1000000*200)    ; should force a fatal memory error if tcsh vmemoryuse limit under 200M
	write "# Fail: didn't produce a memory error on malloc-limit infringement when it should have",!
	halt

memtrap3
	write "# Fail: M trapped malloc-limit infringement when it should have halted",!
	if debug write "debug: si=",si,!
	do allocate(minimum)    ; allocate even more, without increasing the limit: should force a fatal memory error
	write "# Fail: didn't produce a memory error on malloc-limit infringement when it should have",!
	halt

