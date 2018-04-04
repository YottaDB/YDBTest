;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
antifreezeRundown	;
	write "This entryref is not allowed",!
	quit

default	;
	set ^x=1			; Touch the DEFAULT region
	view "FLUSH"			; Flush the updates before suicide
	write "PID=",$job,!		; Record the PID for aid in debugging
	zsystem "kill -9 "_$job		; Suicide, but leave shared memory around
	hang 30				; To take into account asynchronous Kills.
	quit

updatehang	;
	set ^a=1			; Touch the AREG region
	write "PID=",$job,!		; Record the PID for aid in debugging
	for  quit:$data(^astop)  do
	. ; Keep the process attached to AREG's shared memory. Rundown shouldn't remove this.
	. hang 1
	quit

suicide	;
	set ^a($incr(^i))=$j
	set ^x($incr(^i))=$j
	zsystem "kill -9 "_$job
	hang 30	; To account for asynchronous Kills
	quit

updates4reorg	;
	for i=1:1:200 set (^a($incr(^i)),^x($incr(^i)))=$j(i,200)
	for i=1:2:200 kill ^a(i),^x(i) ; kill needed to ensure MUPIP REORG in caller script issues a MUINSTFROZEN message
	quit
