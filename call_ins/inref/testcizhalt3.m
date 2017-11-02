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
	set $etrap="write ""testcizhalt3: ** Error** : "",$zstatus,!,""Aborting testcizhalt3"",!"
	write "testcizhalt3: Entered - driving ZHALT now to return to call-in caller",!
	zhalt 1		     ; Note if any rc but 0 or 1, intoduces a blank line in reference file
