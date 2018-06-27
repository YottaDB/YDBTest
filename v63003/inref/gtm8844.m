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
	set $ztrap="goto incrtrap^incrtrap"
	write "# Halt 1, Expect a RESTRICTEDOP error",!
	halt
	hang:$ZTRNLNM("pause") .5
	write "# Halt 2, Expect a "
	write:'$ZTRNLNM("pause") "fatal "
	write "RESTRICTEDOP error",!
	halt
	; Needed so the second halt and quit don't produce a RESTRICTEDOP error
	hang 1
	quit

zhaltfn
	set $ztrap="goto incrtrap^incrtrap"
	write "# Zhalt 1, Expect a RESTRICTEDOP error",!
	zhalt
	hang:$ZTRNLNM("pause") .5
	write "# Zhalt 2, Expect a "
	write:'$ZTRNLNM("pause") "fatal "
	write "RESTRICTEDOP error",!
	zhalt
	; needed so the second zhalt and quit don't produce a RESTRICTEDOP error
	hang 1
	quit


zgotofn
	set $etrap="do incrtrap^incrtrap"
	zhalt
	write "$ZTRAP=",$ZTRAP,!
	write "$ECODE=",$ECODE,!
	zgoto 0
	quit

triggerfnx
	if ($view("ENVIRONMENT")'["MUMPS")&(^H=0) do
	. zhalt
	quit

triggerfny
	if ($view("ENVIRONMENT")'["MUMPS")&(^H=0)  do
	. halt
	quit


