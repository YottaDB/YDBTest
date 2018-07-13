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
tpnotacid
	tstart ():(serial:transaction="BA")
	if $trestart>2 write /wait(.999)
	else  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	quit
