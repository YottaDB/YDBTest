;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	;
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
	write "# Entered ydb944.m. At this point, cnl->tp_hint would be 0x7ffffffe (2 short of 2**31 if V6 == 4-byte db block)",!
	write "# OR 0x7ffffffffffffffe (2 short of 2**63 if V7 == 8-byte db block)",!
	write "# Now run 100 TP transactions that each allocate a new block",!
	write "#",!
	write "# Before the YDB#944 fixes, cnl->tp_hint would reach 2**31 and we would get a TPFAIL error (eeee)",!
	write "# After the YDB#944 fixes, cnl->tp_hint would be reset to an actual block number so will not reach 2**31",!
	write "#",!
	write "# Before the GTM-DE345399 fixes (e.g. GT.M V7.0-004), cnl->tp_hint would reach 2**63 and we would get an",!
	write "# assert failure in a Debug GT.M build",!
	write "# After the GTM-DE345399 fixes (e.g. GT.M V7.0-005), cnl->tp_hint would reach 2**63 and would be reset to",!
	write "# an actual block number so will not reach 2**63",!
	write "#",!
	write "# That is, we do not expect to see any error below",!
	write "#",!
	for i=1:1:100 do
	. tstart ():serial
	. set ^x(i)=$justify(i,600)
	. tcommit
	quit

