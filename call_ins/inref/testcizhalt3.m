;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See test_ci_z_halt.csh for a description of this test - this is the second target of the call-in
;
testcizhalt3
	new $etrap
	set $etrap="write ""testcizhalt3: ** Error caught ** : "",$zstatus,!,""Aborting testcizhalt3"",! set $ecode="""" quit"
	write "testcizhalt3: Entered - driving ZHALT now to return to call-in caller (expect NOTEXTRINSIC error)",!
	zhalt 42	     ; Not expecting a return value - this will drive an error
