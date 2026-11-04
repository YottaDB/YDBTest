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
ydb1366	; SET $ZSTATUS in the $ETRAP of an error that SET $ECODE raised, then unwind to the caller [YDB#1366]
t(val)	new $etrap
	set $etrap="set $zstatus=val set $etrap=""quit:$quit """""""" quit"" quit:$quit """" quit"
	set $ecode=",U1,"
	quit
