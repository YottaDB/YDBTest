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
; Helper routine for the "noconsumer_*-gtmf228991" subtests (GTM-F228991 in the V7.1-003 release notes).
;
; Both entryrefs run in the same process on purpose. Doing the updates first guarantees this process
; has the database (and therefore the journal pool) open by the time "checkpool" does its $ZPEEK.
;
gtmf228991
	do update
	do checkpool
	quit

update	; Do a few replicated updates.
	new i
	for i=1:1:10 set ^gtmf228991(i)=i
	quit

oneupdate ; Do exactly one simple non-TP update. Used by the "jnlwritereserve_order-gtmf228991"
	; subtest, which runs this under gdb and only cares about one trip through "t_end()".
	set ^gtmf228991("oneupdate")=1
	quit

checkpool ; Print the journal pool fields that GTM-F228991 affects.
	; "write_addr" is the virtual address of the next journal record to be written into the journal
	; pool. Starting V7.1-003, when there is no consumer of the updates in the journal pool (i.e.
	; every source server is either passive or was started with -JNLFILEONLY), updating processes no
	; longer write each commit into the journal pool, so "write_addr" stays at its initialized value
	; of 0. Before V7.1-003, it would be non-zero at this point.
	;
	; "jnl_seqno" on the other hand is instance-wide metadata that continues to be maintained in all
	; cases. Verifying it advanced past its initial value of 1 confirms the updates above did happen
	; and that the $ZPEEK below reads a live journal pool rather than silently returning zeroes. That
	; way a "write_addr = 0" result cannot be a false PASS.
	;
	; Format "U" is used so $ZPEEK returns an unsigned decimal value directly. That is equivalent to,
	; and less ambiguous than, running $$FUNC^%HD() over the default (hexadecimal) representation.
	new jnlseqno,writeaddr
	set writeaddr=$$^%PEEKBYNAME("jnlpool_ctl_struct.write_addr",,"U")
	set jnlseqno=$$^%PEEKBYNAME("jnlpool_ctl_struct.jnl_seqno",,"U")
	write "jnlpool_ctl_struct.write_addr = ",writeaddr,!
	write "jnlpool_ctl_struct.jnl_seqno is greater than 1 : ",$select(1<jnlseqno:"TRUE",1:"FALSE"),!
	quit
