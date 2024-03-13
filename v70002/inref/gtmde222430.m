;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
gtmde222430A;
	use $p:(exception="do exception^"_$text(+0):hupenable)
	ZSHOW "D"
	quit
	;
gtmde222430B
	do
	. new x,$etrap
	use $p:(exception="do exception^"_$text(+0):hupenable)
	set fn="gtmde222430b_exception.log"
	open fn:new
	; Send SIGHUP to current process
	if $zsigproc($job,1)
	; Write to current process (which should fail because we are disconnected)
	; In GT.M V7.0-001/YDB r2.00 this also causes an assert, which shouldn't happen.;
	write "",!
	quit
	;
exception
	new err
	use fn
	write "$ZSTATUS=""",$zstatus,"""",!
	set $ecode=""
	quit
	;
