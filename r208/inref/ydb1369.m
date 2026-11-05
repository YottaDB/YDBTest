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
; Used by the r208/trans2big_kill-ydb1369 subtest
;
restart	; A loop of KILL and SET of ^a(1) in a transaction until TRANS2BIG, then a TRESTART (not in Direct Mode)
	; The error trap goes to "retry" (at the level of the TSTART), with the transaction still open.
	set ^a(1)=1
	set $etrap="write $zstatus,! set $ecode="""" zgoto "_$zlevel_":retry^ydb1369"
	tstart ()
	if '$trestart for i=1:1:1E6 kill ^a(1) set ^a(1)=$justify(1,150)
	write "$tlevel=",$tlevel," $trestart=",$trestart,!
	set ^d=4
	tcommit
	write "$tlevel=",$tlevel,!
	write "end",!
	quit
retry	; Restart the transaction once. If an error comes after the restart, roll the transaction back.
	write "retry $tlevel=",$tlevel," $trestart=",$trestart,!
	if $trestart trollback  write "$tlevel=",$tlevel,!,"end",! quit
	trestart
	quit
fill	; Stage 7 data: ^e(i) with one node in each block, and a subtree ^a(5,*) over many blocks between ^a(4,*) and ^a(6,*)
	for i=1:1:600 set ^e(i)=$justify(i,900)
	for k=4,5,6 for j=1:1:3000 set ^a(k,j)=$justify(j,100)
	quit
partial	; A transaction that updates ^e(i) (one cw_set element each) until it is 2 cw_set elements short of the
	; limit (half the global buffers, less 2, see tp_cw_list.c), then KILLs ^a(5), which needs more than 2 (it
	; changes the blocks at both ends of ^a(5,*) at each level of the tree), so the KILL issues TRANS2BIG
	; after it changed some of those blocks. The error trap goes to "partialc" with the transaction open.
	new limit,i
	set limit=($$^%PEEKBYNAME("sgmnt_data.n_bts","DEFAULT")\2)-2
	set $etrap="write $zstatus,! set $ecode="""" zgoto "_$zlevel_":partialc^ydb1369"
	tstart ()
	for i=1:1:limit-2 set ^e(i)=$justify(i+1E6,900)
	kill ^a(5)
	write "the KILL did not issue TRANS2BIG",!
partialc	; Try to commit, then roll back whatever is left
	set $etrap=""
	write "after the KILL $tlevel=",$tlevel,!
	do commit
	write "after the TCOMMIT $tlevel=",$tlevel,!
	trollback:$tlevel
	write "end",!
	quit
commit	; TCOMMIT, with an error trap that displays the error and goes on
	new $etrap
	set $etrap="write $zstatus,! set $ecode="""" quit"
	tcommit
	quit
