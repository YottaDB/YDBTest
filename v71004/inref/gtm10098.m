;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm10098 ;
	; $ZCMDLINE is "<mode> <cap>" where
	;	mode	"single" performs only HANG on each pass
	;		"cycle"  performs HANG, LOCK and ZSYSTEM on each pass, so that every pass encounters
	;			 three distinct operations capable of causing TPNOTACID detection
	;	cap	the highest $TRESTART this transaction is driven to
	; The TPNOTACID error issued once the retry limit is exceeded is trappable, so $ETRAP reports it.
	new cap,mode
	set mode=$piece($zcmdline," ",1)
	set cap=$piece($zcmdline," ",2)
	set $etrap="do err^gtm10098"
	do trans(mode,cap)
	quit

	; The limit applies to $TRESTART, which counts the restarts of ONE transaction, so the transaction below
	; restarts itself rather than the caller running many short transactions.
	;
	; A TPNOTACID triggering operation runs BEFORE the TRESTART on every pass. That ordering is required: the
	; TPNOTACID check takes the transaction out of its final retry, and an explicit TRESTART is otherwise
	; allowed only once in the final retry (%YDB-E-TRESTMAX). It is also exactly the livelock being limited.
	;
	; HANG, LOCK and ZSYSTEM are each reported by a different module of the source, and each is on its own line
	; here so that every one of them has a distinct $ZPOSITION.
trans(mode,cap)
	new cycle
	tstart ():serial
	set cycle=("cycle"=mode)
	hang .001
	lock:cycle ^gtm10098lock:.002
	zsystem:cycle "exit 0"
	if cap>$trestart  trestart
	tcommit
	lock
	; No restart count is reported here. $TRESTART reads 0 once TCOMMIT has ended the transaction, and the
	; database engine restarts a long running transaction of its own accord often enough that the count at
	; commit is not reproducible. The count that matters is the one the TPNOTACID error itself reports.
	write "Committed without a TPNOTACID error",!
	quit

err	;
	write "Trapped: ",$piece($zstatus,",",3,999),!
	set $ecode=""
	halt
