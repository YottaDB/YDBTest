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
;
; Direct mode cases for the r208/view_trace_errors-ydb1323 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1323dm
	quit

vtnogld
	;inp:$$cycles(35,"view ""trace"":1:""^trace""","view ""trace"":0")
	;inp:"write ""done"",!"
	;has:done
vtcert
	;inp:"kill ^trace"
	;inp:"view ""trace"":1:""^trace"" view ""gdscert"":1 view ""trace"":0:""^ race"""
	;inp:"write ""done"",!"
	;has:done
vtgarbage
	;inp:"kill ^trace"
	;inp:"view ""trace"":1:""^trace"""
	;inp:"view ""trace"":0:""^max set x(i)=$trace"""
	;inp:"write ""done"",!"
	;has:done
