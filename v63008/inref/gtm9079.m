;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This tests for the presence of bug GTM-9079. In GT.M version
;6.3-007, a call to zcompile within an xecute statement produces
;an incorrect code for $ZCSTATUS when compilation fails.
	set $etrap="do error"
	xecute "xecute ""zcompile gtm9079A.m"""
;If the zcompile does not fail, this quits immediately to ensure
;that the program does not fall into the error handling routine.
	quit

error
	write "In error handler",!
	zwrite $ZSTATUS,$ZCSTATUS
	zhalt
