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
haltfn
	set $etrap="do incrtrap^incrtrap"
	write "# Halt 1, Expect a RESTRICTEDOP error",!
	halt
	write "# Halt 2, Expect a RESTRICTEDOP fatal error",!
	halt
	write "Haltfn failed"
	quit

zhaltfn
	set $etrap="do incrtrap^incrtrap"
	write "# Zhalt 1, Expect a RESTRICTEDOP error",!
	zhalt
	write "# Zhalt 2, Expect a RESTRICTEDOP fatal error",!
	zhalt
	write "Zhaltfn failed"
	quit

zgotofn
	set $etrap="do incrtrap^incrtrap"
	zhalt
	write "$ZTRAP=",$ZTRAP,!
	write "$ECODE=",$ECODE,!
	zgoto 0
	quit

