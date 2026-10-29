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
; Direct mode cases for the r208/zcompile_repeat_qual-ydb1321 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1321dm
	quit

zcrepeat
	;inp:"zlink ""test.m"":""-n=-1ject -lis=-1ject -list"""
	;inp:"zlink ""test.m"":"".noobject -qwerty"""
	;inp:"zcompile ""-list=y.lis -list a.m"""
	;inp:"zcompile ""b.m"""
	;inp:"zcompile ""c.m"""
	;inp:"write ""region="",$view(""REGION"",""^efgh""),!"
	;has:region=DEFAULT
