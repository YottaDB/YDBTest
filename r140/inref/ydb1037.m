;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; The below example is based on the sample program at https://gitlab.com/YottaDB/DB/YDB/-/issues/1037#description
; The latter would run into an infinite loop after the #1037 code fixes so we instead measure M stack usage below
; after a few thousand iterations and make sure it has not changed across lots of iterations.

ydb1037	;
	new cnt,stksize
	set $ztrap="do HDL"
	write 1/0
	quit
HDL ;
	if $increment(cnt)>10000 write "PASS : Executed 10,000 iterations without STACKCRIT error",! halt
	quit

