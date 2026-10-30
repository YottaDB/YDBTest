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
; Helper M program used by the r208/invdlrcval_value-ydb1343 subtest (UTF-8 mode). Compiling it issues the INVDLRCVAL
; warning for the line below, and running that line issues the INVDLRCVAL error.
;
ydb1343bad
	set x=$char(65,1114112)
	quit
