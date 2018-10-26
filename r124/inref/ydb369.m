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
ydb369	;
	do ^sstep
	do @$ZCMDLINE
	quit
case1	;
	set case1="case1"
	VIEW "SETENV":"ydb369_var":case1
	write $ZTRNLNM("ydb369_var")
	quit

case2	;
	set case2="case=2"
	VIEW "SETENV":"ydb369_var":case2
	write $ZTRNLNM("ydb369_var")
	quit

case3	;
	VIEW "SETENV":"ydb369_var":"abc""def"
	write $ZTRNLNM("ydb369_var")
	quit

case4	;
	VIEW "SETENV"
	quit

case5	;
	VIEW "SETENV":""
	quit

case6	;
	VIEW "SETENV":"":""
	quit

case7	;
	VIEW "SETENV":"ydb369_var":""
	write $ZTRNLNM("ydb369_var")
	quit

case8	;
	VIEW "SETENV":"ydb369_var":"case8"
	write $ZTRNLNM("ydb369_var")
	quit

case9	;
	VIEW "SETENV":"ydb369_var":"case9":"extra"
	write $ZTRNLNM("ydb369_var")
	quit

case10	;
	VIEW "SETENV":"x=y":"case10":"extra"
	write $ZTRNLNM("x=y")
	quit

case11	;
	set a="ydb369_var"
	set b="case11"
	VIEW "SETENV":a:b
	write $ZTRNLNM("ydb369_var")
	quit

case12	;
	VIEW "SETENV":"ydb369_var":"case12"
	write $ZTRNLNM("ydb369_var")
	VIEW "UNSETENV":"ydb369_var"
	write $ZTRNLNM("ydb369_var")
	quit
