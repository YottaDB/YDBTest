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
; Direct mode cases for the r208/trap_tstart_hang-ydb1332 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1332dm
	quit

filestrapdm	; A routine that divides by zero
	open "ydb1332x.m":(newversion) use "ydb1332x.m" write "ydb1332x"_$char(9)_"write 1/0",!,$char(9)_"quit",! close "ydb1332x.m"
	quit
trapdm
	;inp:"do ^ydb1332x"
	;inp:"tstart"
	;inp:"zcontinue"
	;inp:"write ""next $tlevel="",$tlevel,!"
	;has:DIVZERO
	;has:TPQUIT
	;has:next $tlevel=0
