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
;
; ZWRITE an "orphaned" alias container, that is, a container whose target base variable no longer has a
; name in the symbol table. That dump runs through the "dump_container" branch of lvzwr_out(), which
; allocates its own per-subscript work array. That allocation used to be sized MAX_LVSUBSCRIPTS while
; lvzwr_var() writes the slot for the level it is visiting, so a target node at the maximum depth of
; MAX_LVSUBSCRIPTS (31) subscripts wrote one element past the end of the allocation.
;
ydb1101zwr	;
	new nsubs
	set nsubs=$piece($zcmdline," ",1)
	write "# ZWRITE an orphaned alias container whose target is ",nsubs," subscripts deep",!
	do dump(nsubs)
	write "# PASS: ZWRITE completed without overflowing the subscript work array",!
	quit
	;
dump(nsubs)	; build newo(1,1,...,1) with "nsubs" subscripts, container it, orphan it, then ZWRITE it
	new i,subs
	set subs="" for i=1:1:nsubs set subs=subs_$select(1<i:",",1:"")_"1"
	set @("newo("_subs_")")=42
	set *ct(1)=newo		; ct(1) becomes an alias container referencing newo's data
	kill *newo		; orphan it: the name "newo" is gone but the data lives on through ct(1)
	kill i,subs,nsubs	; keep the ZWRITE output down to just the container and its target
	zwrite
	quit
