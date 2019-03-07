;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8023	;
	set $etrap="goto errorAndCont^errorAndCont"
	set ^notpossible=1
	write "# Wait for freeze : ",$zdate($H,"24:60:SS"),!
	zsystem ("$gtm_tst/com/wait_for_log.csh -log freeze.done -waitcreation")
	write "# Instance frozen : ",$zdate($H,"24:60:SS"),!
	zsystem ("grep FREEZE_BY_BGPROCESS passive*")
	; Do not modify the below write - gtm8023_bgprocess.csh waits for the below message
	write "# Now do a zwrite of global - Should hang",!,$zdate($H,"24:60:SS"),!
	zwrite ^noreorg
	write $zdate($H,"24:60:SS"),!
	for i=1:1:3600 quit:$data(^nowprimary)  hang 1
	if i=3600 write "gtm8023-E-Timeout",! quit
	; The side is now primary
	set ^nowpossible("gtm8023")=1
	quit

readonly	;
	set $etrap="goto errorAndCont^errorAndCont"
	for i=1:1:3600 quit:$data(^nowprimary)  hang 1
	if i=3600 write "gtm8023-E-Timeout",! quit
	; The side is now primary
	set ^nowpossible("readonly^gtm8023")=1
	quit

