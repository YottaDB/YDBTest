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
; Direct mode cases for the r208/view_trace_subs-ydb1324 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1324dm
	quit

vtsubs26
	;inp:"view ""trace"":1:""^t26(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)"""
	;inp:"for i=1:1:3 set x=i"
	;inp:"view ""trace"":0"
	;inp:"write ""$data(^t26)="",$data(^t26),!"
	;has:$data(^t26)=10
vtsubs27
	;inp:"view ""trace"":1:""^t27(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)"""
	;inp:"for i=1:1:3 set x=i"
	;inp:"view ""trace"":0"
	;inp:"write ""$data(^t27)="",$data(^t27),!"
	;has:$data(^t27)=0
