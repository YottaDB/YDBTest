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
; See test_ci_z_halt.csh for a description of this test - this is the first target of the call-in
;
testcizhalt2
	new $etrap
	set $etrap="write ""testcizhalt2: ** Error** : "",$zstatus,!,""Aborting testcizhalt2"",!"
	write "testcizhalt2: Entered - driving HALT now to return to call-in caller",!
	halt
