;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; attempts to set 100 locks and should not hang after the 33rd
; after it sets the flag ^done(1) and waits for the check process to finish
; requires the environment variable ydb_lockhash_n_bits=1
lockhashloopA ;
	set hashbits=$ztrnlnm("ydb_lockhash_n_bits")
	if hashbits'=1 write "ydb_lockhash_n_bits is not correct Expected: 1; Actual: ",hashbits,! quit
	set ^loopApid=$job
	for i=1:1:100 write "lock +^a(",i,")",! lock +^a(i) set ^aLock(i)=1


	; if all 100 locks have been obtained hang until the check is done
	set ^done(1)=1
	for  quit:$get(^exit(1))=1  hang 0.01
	quit


; attempts to set 47 locks and should not hang on the 47th
; after it sets the flag ^done(2) and waits for the check process to finish
; does not require ydb_lockhash_n_bits=1 as the values have been picked to cause a collision
lockhashloopB ;
	set hashbits=+$ztrnlnm("ydb_lockhash_n_bits")
	if hashbits'=0 write "ydb_lockhash_n_bits is not correct Expected: 0; Actual: ",hashbits,! quit
	set ^loopBpid=$job
	set substr="1445240077 4097034630 4388659035 4630999867 5407955935 6251931759 11417300836 10290985601"
        set substr=substr_" 11005068295 11434779216 12514012645 12676101741 17058576286 18738986112 18480244186 17280277179"
        set substr=substr_" 18379984114 24440525326 21696035853 25089805580 25561658649 29582647612 30357044280 27414314996"
        set substr=substr_" 32074740586 28582294681 31467579889 36848531774 46427764934 41893554996 48113940994 43052926029"
        set substr=substr_" 44129775493 47697200707 54939630888 55988509030 57060549750 51493002061 60309326336 53984812611"
        set substr=substr_" 54917189673 61308148430 56066818915 56431408489 63495468474 68545605854 66623834096"
	for i=1:1:$length(substr," ") set toLock=$piece(substr," ",i) write "lock +^a(",toLock,")",! lock +^a(toLock) set ^aLock(toLock)=1

	; if all 47 locks have been obtained hang until the check is done
	set ^done(2)=1
	for  quit:$get(^exit(2))=1  hang 0.01
	quit


; starts a timeout after the 32nd lock is set by lockhashloopA and then waits for the ^done(1) flag to be set
; if it is not set by the timeout lockhashloopA is considered hung and is killed
; to prevent runaway shared memory usage
lockMonitorA ;
	for i=1:1  quit:$get(^aLock(32))=1  hang 0.001
	; use the counter i to estimate a practical wait time for ^a(100)
	; this is to have a flexible timeout for slower and faster systems
	hang 100*i*0.001

	set numCollisions=$$^%PEEKBYNAME("sgmnt_data.lock_hash_bucket_full_cntr","DEFAULT")
	if numCollisions=70 write "PASS: numCollisions is correctly 70",!
	else  write "FAIL: numCollisions is not correct Expected: 70; Actual: ",numCollisions,!

	if $get(^done(1))=1 write "PASS: lockhashloopA got ^a(100)",! set ^exit(1)=1
	else  write "FAIL: lockhashloopA is probably hung. Killing process to prevent runaway shared memory usage",! write $zsigproc(^loopApid,15)
	use $p
	quit


; starts a timeout after the 46th lock is set by lockhashloopA and then waits for the ^done(1) flag to be set
; if it is not set by the timeout lockhashloopA is considered hung and is killed
; to prevent runaway shared memory usage
lockMonitorB ;
	for i=1:1  quit:$get(^aLock(68545605854))=1  hang 0.001
	; use the counter i to estimate a practical wait time for ^a(66623834096)
	; this is to have a flexible timeout for slower and faster systems
	hang i*0.001

	set numCollisions=$$^%PEEKBYNAME("sgmnt_data.lock_hash_bucket_full_cntr","DEFAULT")
	if numCollisions=16 write "PASS: numCollisions is correctly 16",!
	else  write "FAIL: numCollisions is not correct Expected: 16; Actual: ",numCollisions,!

	if $get(^done(2))=1 write "PASS: lockhashloopA got ^a(66623834096)",! set ^exit(2)=1
	else  write "FAIL: lockhashloopB is probably hung trying to obtain ^a(66623834096). Killing process to prevent runaway shared memory usage",! write $zsigproc(^loopBpid,15)
	use $p
	quit
