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
; See replace_rtn.csh for a description of this test - this is the target of the call-in
;
testmprofhiddenrtn2
	new $etrap
	set $etrap="write ""testmprofhiddenrtn2: ** Error** : "",$zstatus,!,""Aborting testmprofhiddenrtn2"",!"
	write "testmprofhiddenrtn2: Entered",!
	write "testmprofhiddenrtn2: Returning",!
	quit
