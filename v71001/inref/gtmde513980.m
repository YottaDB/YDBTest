;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde513980 ;
	; Do initial database access outside of the transaction to perform
	; encryption operations prior to the transaction. That way, the ~0.5
	; seconds needed for encryption setup do not impact the transaction runtime.
	set x=$get(^x)
	set $zmaxtptime=2
	zwrite $zmaxtptime
	set $etrap="zwrite $h,$zstatus  halt"
	tstart ():serial
	if $trestart<3 trestart
	set x=$get(^x)
	write "$h = ",$h," : $trestart = ",$trestart," : BEFORE hang 15",!
	hang 15
	write "$h = ",$h," : $trestart = ",$trestart," : BEFORE tcommit",!
	tcommit
	quit
