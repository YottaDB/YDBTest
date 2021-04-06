; The below updates rely on the below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

updates	;
	; Function that performs large updates to fill jnlpool quickly
	; It checks if 4 times jnlpool size has been written and if so quits.
	; Note that imptp processes are running in background too and would be
	; writing to jnlpool concurrently. This takes that into account too
	; since it looks at a field in the jnlpool shared memory to know when to stop.
	set jnlpoolsize=$$^%PEEKBYNAME("jnlpool_ctl_struct.jnlpool_size")
	set start=$$FUNC^%HD($$^%PEEKBYNAME("jnlpool_ctl_struct.write_addr")),end=start+(4*jnlpoolsize)
	for i=1:1 do  quit:(end<$$FUNC^%HD($$^%PEEKBYNAME("jnlpool_ctl_struct.write_addr")))
	. set val=$$^ulongstr(8064-i)
	. set val1=$justify(val,8064)
	. set ^aglobalvariable(i,$job)=val
	. set ^bglobal(i,$job)=val
	. set ^c(i,$job)=val
	. set ^dglobal(i)=val
	. set ^e=val
	. set ^fgbl($job)=val
	quit
