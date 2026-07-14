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
ydb1245	; Routines for the reorg_trunc_concurrent-ydb1245 subtest (YDB#1245)
	quit
	;
inita	; Create ^a1 and ^a2 and then kill ^a1. This leaves the database file with lots of free space in its
	; first half (the killed ^a1) while the blocks of ^a2 occupy the second half.
	new i
	for i=1:1:200000 set ^a1(i)=$justify(1_i,200)
	for i=1:1:200000 set ^a2(i)=$justify(2_i,200)
	kill ^a1
	quit
	;
initb	; Create ^b1 and ^b2. This runs concurrently with a MUPIP REORG -TRUNCATE. Since these globals did not
	; exist when the REORG started, its reorg phase does not know about them, which is what YDB#1245 tests.
	new i
	for i=1:1:20000 set ^b1(i)=$justify(1_i,200)
	for i=1:1:20000 set ^b2(i)=$justify(1_i,200)
	quit
