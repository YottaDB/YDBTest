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
	;
killb	; Kill ^b1 and ^b2 so the MUPIP REORG -TRUNCATE that the caller runs next can compact ^a2 to the front of
	; the database file and truncate away everything above it.
	kill ^b1,^b2
	quit
	;
initc	; Strand a few blocks of the huge ^a2 at the very end of the database file, with lots of free space below
	; them. At entry ^a2 is compacted at the front (the caller just ran a standalone REORG -TRUNCATE) and there
	; is almost no free space left in the file. So, in order:
	;   1) ^filler extends the file well past ^a2's last block;
	;   2) the new ^a2 records below then find no free block anywhere and have to extend the file further
	;      still, which puts the handful of blocks they need at the very end of it;
	;   3) killing ^filler frees up the whole region in between.
	; The result is the shape this subtest wants to measure, and the shape a user database is in when a REORG
	; -TRUNCATE has real work to do: a global occupying (almost) the whole file, of which only a few blocks are
	; anywhere near the end. A [REORG -TRUNCATE -SELECT=a1,filler] then has nothing to do except sweep those
	; few blocks: ^a1 was killed by [inita] and ^filler is killed below, so reorging either costs nothing,
	; leaving the tail sweep as the only thing in that process doing any appreciable work.
	;
	; ^filler has to be selected by that REORG even though it is killed here: the kill leaves ^filler's (now
	; empty) GVT root block behind, and since that root was allocated late in the growth below it sits near the
	; end of the file. One busy block in the last local bitmap pins the whole file (see the comment before the
	; -select in the .csh), and nothing but a reorg of ^filler itself moves that block.
	new i
	for i=1:1:100000 set ^filler(i)=$justify(1_i,200)
	for i=200001:1:201000 set ^a2(i)=$justify(2_i,200)
	kill ^filler
	quit
