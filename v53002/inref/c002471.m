;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2008-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002471	;
	; C9D12-002741 Previous to this support, GTM drove its error handlers on a MEMORY/VMSMEMORY type error.
	; With this support, these errors are now fatal so no (M) error handlers are driven. These tests are
	; to verify that in an out of storage condition, we successfully generate a FATAL_ERROR file and exit
	; cleanly with no core/dump file. We have two ways of testing this. One is a coarse allocation failure
	; (which used to be run as v44004/C9D11002455) that usually fails allocating a large chunk of storage as
	; part of a TP transaction and the other is a finer grain storage failure which is creating massive
	; numbers of global variables in storage (by referencing undefined globals).
	;

	; Test that huge TP transactions which cause MEMORY overflow errors do not ACCVIO

setup;
	set limit=+$ztrnlnm("gtm_test_vlimit")
	if ('limit) write "TEST-E-FAIL, gtm_test_vlimit is not set.",! zhalt 1
	if $&utils.setrlimit(limit,.errno)
	quit

test1;
	do:($zversion'["AIX")&($zversion'["HP-UX") setup
	write "Starting test1",!
	do makevars	; allocate some local vars to make the YDB_FATAL_ERROR file somewhat interesting
	do bigtp	; do allocations inside TP until we explode
	quit		; should never get here

	; Create large number of global anchors in storage by referencing undefined globals
test2;
	do:($zversion'["AIX")&($zversion'["HP-UX") setup
	write "Starting test2",!
	do makevars	; allocate some local vars to make the YDB_FATAL_ERROR file somewhat interesting
	do makegblrefs	; make global references till we explode
	quit		; should never get here

makevars;
	for i=1:1:500 s $piece(aLocalVar(i),i#10,i*2)=""
	quit

bigtp	;
	tstart ():serial
	for unit=1:1  for i=1:1:1000 set ^dummy(i#11,i#13,$j(i,40))=$j(i,$r(200))
	tcommit	   ; should never get here
	quit

makegblrefs;
	for gblcnt=1:1  set x="^gbl"_gblcnt s y=$get(@x)
	quit	   ; should never get here

memholder;
	; This entry point is not normally used but can be useful in debugging on VMS. If either test (but especially test2)
	; starts to generate assert failures and dumps, chances are good those dumps will not be readable because they will be
	; too large. The purpose of this entry point is to create a "sub-process" that will grab a sustantial chunk of memory
	; (using local vars of large length) against the same page file quota and then exit when the main process "fails". The
	; theory being that the dump file that will be created will happen "sooner" in the smaller space and will not have the
	; storage used by this sub-process and thus successfully be able to run the debugger.
	;
	if $ZVersion'["VMS" Write "This is a VMS-only entry point",! Halt
	lock tilldead  ; when subprocess gets this lock, this main process will be gone
	job @("memsubproc^c002471:(nodetached:startup=""startup.com"":output=""memsubproc.mjo"":error=""memsubproc.mje"")")
	quit

memsubproc;
	; The sub-process used to consume some space (about 16MB) then die when the lock becomes available
	;
	if $ZVersion'["VMS" Write "This is a VMS-only entry point",! Halt
	for i=1:1:16 s $piece(memwaste(i),";",1048570)=""
	lock tilldead
	halt
