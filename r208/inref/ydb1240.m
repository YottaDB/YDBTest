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
ydb1240	; Routines for the reorg_trunc_hidden_gbl-ydb1240 subtest (YDB#1240)
	quit
	;
inita	; Grow ^x and then create ^a, whose blocks land at the very end of the grown file; then kill both.
	; The kills leave both names in region DEFAULT's directory tree, each pointing to a leftover empty root
	; block. ^a's root block is the interesting one: it sits at the very end of the file and, once the name
	; [a] is mapped to another region (see the .csh), nothing in a pre-YDB#1240 REORG -TRUNCATE would move
	; it, so it alone pins the file at (about) its full size.
	do growx
	set ^a=1
	kill ^a,^x
	quit
	;
initb	; Regrow ^x, create ^b (WITH data, unlike [inita]'s killed ^a) at the end of the file, then kill only
	; ^x. ^b becomes a hidden global with data once the .csh switches to the gld that maps [b] elsewhere.
	do growx
	do fill("^b")
	kill ^x
	quit
	;
initc	; Same shape as [initb] but for ^c; used by the tail sweep stage of the subtest.
	do growx
	do fill("^c")
	kill ^x
	quit
	;
initx	; Regrow and kill ^x, so the database file again has lots of free space for a truncate to reclaim.
	do growx
	kill ^x
	quit
	;
growx	; Grow ^x big enough that the database file spans several local bitmaps (512 blocks each): 25000
	; records of ~200 bytes come to ~1400 4096-byte blocks, i.e. 3 local bitmaps. Whatever a caller creates
	; right after this lands at the very end of the grown file, which is what makes the globals the callers
	; create good truncate blockers.
	new i
	for i=1:1:25000 set ^x(i)=$justify(i,200)
	quit
	;
fill(gbl)	; Create 50 records under @gbl (small on purpose: these globals exist to pin the end of the file,
	; not to add runtime; 50 records also keep the [verify] scan cheap)
	new i
	for i=1:1:50 set @gbl@(i)=$justify(i,200)
	quit
	;
verifyb	; Verify (through a gld that maps [b] to region DEFAULT) that ^b survived its block moves intact
	do verify("^b")
	quit
	;
verifyc	; Verify (through a gld that maps [c] to region DEFAULT) that ^c survived its block moves intact
	do verify("^c")
	quit
	;
verify(gbl)	; Check that exactly the records [fill] created under @gbl are present and unchanged. The blocks
	; of @gbl were relocated by a MUPIP REORG (block swaps and a root block move), so this is a data
	; integrity check of those moves.
	new bad,cnt,sub
	set (bad,cnt)=0,sub=""
	for  set sub=$order(@gbl@(sub)) quit:""=sub  do
	. set cnt=cnt+1
	. if $get(@gbl@(sub))'=$justify(sub,200) set bad=bad+1
	write "Verified contents of ",gbl," : ",$select((0=bad)&(50=cnt):"OK",1:"FAIL ("_cnt_" records, "_bad_" bad)"),!
	quit
