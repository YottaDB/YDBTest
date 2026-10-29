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
; Direct mode cases for the r208/zgoto_dmod-ydb1328 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1328dm
	quit

zgdmod
	;inp:"set x=$char(0)_""dummy"""
	;inp:"zgoto $zlevel-1:@x"
	;inp:"write ""next line ran"",!"
	;inp:"write ""$zlevel="",$zlevel,!"
	;has:RTNNAME
	;has:next line ran
	;has:$zlevel=1
	;not:NOTMNAME
