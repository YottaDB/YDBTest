;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
; Helper M program used by r136/u_inref/ydb951.csh
;
ydb951	;
	set file="/dev/null"
	open file:readonly
	use $principal
	; Note that string literal usage in this M program is very limited as they affect whether the test exercises
	; the buggy code path or not. That is why comments are used below instead of "write" commands (which would
	; have been more helpful in a reference file to understand the flow/expectation of the test).
	zshow "d"	; This ZSHOW command used to previously incorrectly show EXCEPTION string for /dev/null
	use file
	read head:0	; This read command used to previously issue a %YDB-E-CMD error
	set dummy="GDSDYNUNX,U241,"
	quit

