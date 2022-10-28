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


;
; Helper M program used by r136/u_inref/ydb944.csh
;
ydb944	;
	kill ^x
	set ^x=1
	write "# Entered ydb944.m. At this point, cnl->tp_hint would be 0x7ffffffe (2 short of 2GiB)",!
	write "# Now run 100 TP transactions that each allocate a new block",!
	write "# Before the YDB#944 fixes, cnl->tp_hint would reach 2GiB and we would get a TPFAIL error (eeee)",!
	write "# After the YDB#944 fixes, cnl->tp_hint would be reset to an actual block number so will not reach 2GiB",!
	write "# And therefore, we would not get any error (which is what we expect to see below)",!
	for i=1:1:100 do
	. tstart ():serial
	. set ^x(i)=$justify(i,600)
	. tcommit
	quit

