;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Script to verify that concurrently linking multiple version of the same routine results in correct numver
; counts in rtnobj shared memory.
numver

; There are three processes participating in this test, each one having objXDS as an autorelinked-enabled directory in its
; $zroutines. Process A executes routine rtnWEH and starts process B, which compiles a different version of the routine and
; links it, but then recompiles the original version to the same location. Process A then reexecutes the routine, which,
; although it has been ZRUPDATEd (due to process B's ZLINK), should not result in cycle number bump because process A still
; has the original version linked, and it perfectly matches with what it finds on disk. Next, process A invokes process C,
; which also executes rtnWEH, but since it is found in shared memory, there is still no cycle update. Finally, A does one
; more execution of rtnWEH, and, since it still is linked to the original object, that does not affect the cycle.
; MUPIP RCTLDUMPs are taken at relevant points of this test for further validation.
procA
	set procBStarted=0
	set procCStarted=0
	lock +^procBTerminate
	lock +^procCTerminate

	set $zroutines="objXDS*(srcBKH)"
	do rtnWEH^rtnWEH

	set jobCmd="procB^numver:(output=""procB.mjo"":error=""procB.mje"")"
	job @jobCmd
	for i=1:1:120 lock +^procB:0 set:('$test) procBStarted=1 quit:procBStarted  lock:('procBStarted) -^procB hang 1
	if ('procBStarted) write "TEST-E-FAIL, Failed to start and execute process B in 120 seconds.",! zhalt 1

	zsystem "$gtm_dist/mupip rctldump objXDS >&! rctldump-1.log"
	do rtnWEH^rtnWEH
	zsystem "$gtm_dist/mupip rctldump objXDS >&! rctldump-2.log"

	set jobCmd="procC^numver:(output=""procC.mjo"":error=""procC.mje"")"
	job @jobCmd
	for i=1:1:120 lock +^procC:0 set:('$test) procCStarted=1 quit:procCStarted  lock:('procCStarted) -^procC hang 1
	if ('procCStarted) write "TEST-E-FAIL, Failed to start and execute process C in 120 seconds.",! zhalt 1

	do rtnWEH^rtnWEH
	zsystem "$gtm_dist/mupip rctldump objXDS >&! rctldump-4.log"

	lock -^procBTerminate
	lock -^procCTerminate

	quit

procB
	set $zroutines="objXDS*"
	hang 0.01
	zcompile "-object=objXDS/rtnWEH.o srcSJA/rtnWEH.m"
	zlink "objXDS/rtnWEH.o"
	hang 0.01
	zcompile "-object=objXDS/rtnWEH.o srcBKH/rtnWEH.m"
	lock +^procB:60
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procB in 60 seconds." zhalt 1
	lock +^procBTerminate:120
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procBTerminate in 120 seconds." zhalt 1
	quit

procC
	set $zroutines="objXDS*"
	do rtnWEH^rtnWEH
	zsystem "$gtm_dist/mupip rctldump objXDS >&! rctldump-3.log"
	lock +^procC:60
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procC in 60 seconds." zhalt 1
	lock +^procCTerminate:120
	if ('$test) write "TEST-E-FAIL, Failed to obtain lock ^procCTerminate in 120 seconds." zhalt 1
	quit
