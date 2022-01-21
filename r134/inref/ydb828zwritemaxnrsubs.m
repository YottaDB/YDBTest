;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb828zwritemaxnrsubs
	; ----------------------------------------------------------------------------------
	; Test that > 31 subscripts in ZWRITE does not cause SIG-11 OR heap-buffer-overflow error (with ASAN)
	; We expect MAXNRSUBSCRIPTS error in this case (which is checked by "etrap" entryref below)
	; ----------------------------------------------------------------------------------
	;
	; i=0 and i=1 raises this error   : %YDB-E-LVUNDEF, Undefined local variable: x(1)
	; i=2 to i=31 raises NO error
	; i=32 to i=248 raises this error : %YDB-E-MAXNRSUBSCRIPTS, Maximum number of subscripts exceeded
	; i>=249      raises this error   : %YDB-E-MAXARGCNT, Maximum number of arguments 253 exceeded
	; Hence the below range of i to avoid having to accept LVUNDEF/MAXARGCNT errors as expected in the "etrap" entryref
	for i=2:1:248 do
	. set (x,^x)=i
	. for var="?1E","x","^x" do
	. . set xstr="zwrite "_var_"(1"_$translate($justify(",",i)," ",",")_")"
	. . do execute(xstr)
	write "ydb828zwritemaxnrsubs : PASSED",!
	quit

execute(xstr)
	new $etrap
	set $etrap="do etrap"
	xecute xstr
	quit

etrap	;
	; Only allow the following errors as expected. Any other error is unexpected and we halt the program in that case.
	;	%YDB-E-MAXNRSUBSCRIPTS, Maximum number of subscripts exceeded
	if ($zstatus["YDB-E-MAXNRSUBSCRIPTS") set $ecode=""
	else  zshow "*" halt
	quit

