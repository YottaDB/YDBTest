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
	halt
	halt
	quit

zhaltfn
	set $etrap="do incrtrap^incrtrap"
	zhalt
	zhalt
	quit

zgotofn
	set $etrap="do incrtrap^incrtrap"
	zhalt
	write "$ZTRAP=",$ZTRAP,!
	write "$ECODE=",$ECODE,!
	zgoto 0
	quit
