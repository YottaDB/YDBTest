;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Triggers the JOBLVN2LONG error

joblvn2longmsg
	; Add 4 to size because of the zwrite rep. -> x=""
	; The total size is 1048577 which exceeds 1MB by one
	set x=$translate($justify(" ",2**20-4+1)," ","X")
	job child:passcurlvn
	quit
child
	write "TEST-E-FAIL This should never be executed",!
	quit
