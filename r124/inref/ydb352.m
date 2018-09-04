;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb352	;
	write "ydb352.m : Attempting to set ^x to a value of 2000 bytes when maximum record size is 1024. Expecting a REC2BIG error",!
	set ^x=$justify(1,2000)	; this should cause a REC2BIG error since record_size is set to 1024 in db
	write "ydb352.m : Do not expect control to reach this line",!
	quit
