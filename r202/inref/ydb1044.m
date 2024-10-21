;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1044 ; just quit
	quit

argc1	; TEST_CASE: too many args, command 1
	set czff=$zsocket("","zff",t,onopen,"cz write ")
	quit

argc2	; TEST_CASE: too many args, command 2
	set czff=$zsocket("","zff",t,onopen,usfbefore,useafter,"cz write ")
	quit

mlab	; TEST_CASE: missing label
	set x=$order(^one) do show("^one(1)",x)
	quit

pc1	; TEST_CASE: postcond issue, command 1
	set:$f x
	new j
	quit

pc2	; TEST_CASE:  postcond issue, command 2
	use:0
	set x=""
	quit

pc3	; TEST_CASE: postcond issue, command 3
	write:$f
	set x=1
	quit
