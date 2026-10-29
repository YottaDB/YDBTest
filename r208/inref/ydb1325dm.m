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
; Direct mode cases for the r208/new_ztrap_stackcrit-ydb1325 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1325dm
	quit

ztnew
	;inp:"for  new $ztrap"
	;inp:"write ""$length($ztrap)="",$length($ztrap),!"
	;inp:"write 1/0"
	;has:STACKCRIT
	;not:INDRMAXLEN
	;not:ERRWETRAP
	;not:ERRWZTRAP

ztuse
	;inp:"for  new $ztrap"
	;inp:"write $ztrap,!"
	;has:STACKCRIT
