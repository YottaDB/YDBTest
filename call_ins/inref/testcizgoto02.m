;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; See test_ci_zgoto0.csh for a description of this test - this is the first target of the call-in
;
testcizgoto02
	new $etrap
	set $etrap="write ""testcizgoto02: ** Error** : "",$zstatus,!,""Aborting testcizgoto02"",!"
	write "testcizgoto02: Entered - driving ZGOTO 0 now to return to call-in caller",!
	zgoto 0
	write "testcizgoto02: Should never happen",!
	zhalt 99
