;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
; Helper M program used by the r208/zpeek_int8-ydb1351 subtest. Each label calls $$^%PEEKBYNAME() (and so $ZPEEK()) on
; the 8-byte field node_local.nbb with one format at many stringpool offsets, and prints PASS or FAIL.
;
fmtU	; The "U" (unsigned integer) format
	do sweep("U")
	quit
fmtI	; The "I" (signed integer) format
	do sweep("I")
	quit
sweep(fmt)	; Vary the stringpool free space with a padding string of k bytes, then peek 200 times for each k
	new expect,i,k,pad,x
	set expect=$$^%PEEKBYNAME("node_local.nbb","DEFAULT",fmt)
	if 11>$length(expect) write "FAIL : node_local.nbb is [",expect,"], expected a value of more than 10 digits",! quit
	set x=expect
	for k=1:1:500 quit:x'=expect  set pad=$justify(k,k) for i=1:1:200 set x=$$^%PEEKBYNAME("node_local.nbb","DEFAULT",fmt) quit:x'=expect
	if x'=expect write "FAIL : format ",fmt," returned [",x,"] at k=",k," i=",i,", expected ",expect,! quit
	write "PASS : format ",fmt," returned ",expect," at every stringpool offset",!
	quit
