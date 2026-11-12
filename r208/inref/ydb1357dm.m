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
; Direct mode cases for the r208/zcontinue_tpquit-ydb1357 subtest, run by r208/u_inref/ydbfuzzdm.csh. The stages of
; that subtest describe the cases.
;
ydb1357dm
	quit

zcont
	;inp:"break"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the first ZCONTINUE $tlevel="",$tlevel,!"
	;inp:"tcommit"
	;inp:"zcontinue"
	;inp:"write ""after the second ZCONTINUE $tlevel="",$tlevel,!"
	;has:after the first ZCONTINUE $tlevel=1
	;has:after the second ZCONTINUE $tlevel=0
	;not:TLVLZERO
zcontline
	;inp:"break  write ""rest of the BREAK line $tlevel="",$tlevel,!"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the first ZCONTINUE $tlevel="",$tlevel,!"
	;inp:"trollback"
	;inp:"zcontinue"
	;has:after the first ZCONTINUE $tlevel=1
	;has:rest of the BREAK line $tlevel=0
	;not:TLVLZERO
filesztrap	; A routine that divides by zero
	open "ydb1357x.m":(newversion) use "ydb1357x.m" write "ydb1357x"_$char(9)_"write 1/0",!,$char(9)_"quit",! close "ydb1357x.m"
	quit
ztrap
	;inp:"do ^ydb1357x"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,!"
	;inp:"trollback"
	;has:DIVZERO
	;has:after the ZCONTINUE $tlevel=1
filesrtn	; A routine that does a BREAK and then commits the transaction
	open "ydb1357r.m":(newversion) use "ydb1357r.m"
	write "ydb1357r"_$char(9)_"break",!
	write $char(9)_"write ""in ydb1357r after the BREAK $tlevel="",$tlevel,!",!
	write $char(9)_"tcommit",!
	write $char(9)_"quit",!
	close "ydb1357r.m"
	quit
rtn
	;inp:"do ^ydb1357r"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,!"
	;has:in ydb1357r after the BREAK $tlevel=1
	;has:after the ZCONTINUE $tlevel=0
	;not:TPQUIT
prompt
	;inp:"break"
	;inp:"tstart ()"
	;inp:"tcommit"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,!"
	;has:after the ZCONTINUE $tlevel=0
	;not:TPQUIT
fileszbrk	; A routine with two lines, for a ZBREAK
	open "ydb1357z.m":(newversion) use "ydb1357z.m"
	write "ydb1357z"_$char(9)_"write ""line1"",!",!
	write $char(9)_"write ""line2"",!",!
	write $char(9)_"quit",!
	close "ydb1357z.m"
	quit
zbrk
	;inp:"zbreak ydb1357z^ydb1357z:""break"""
	;inp:"do ^ydb1357z"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,"" $ecode=["",$ecode,""]"",!"
	;inp:"zshow ""s"""
	;inp:"trollback"
	;inp:"zcontinue"
	;has:BREAKZBA
	;has:after the ZCONTINUE $tlevel=1 $ecode=[]
	;has:line2
	;not:ERRWZBRK
	;not:($ZTRAP)
fileszstp	; The same routine, for a ZBREAK and a ZSTEP
	do fileszbrk
	quit
zstp
	;inp:"zbreak ydb1357z^ydb1357z"
	;inp:"do ^ydb1357z"
	;inp:"zstep"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,"" $ecode=["",$ecode,""]"",!"
	;inp:"zshow ""s"""
	;inp:"trollback"
	;inp:"zcontinue"
	;has:BREAKZST
	;has:after the ZCONTINUE $tlevel=1 $ecode=[]
	;has:line2
	;not:ERRWEXC
	;not:($ZTRAP)
filesexc	; A routine whose READ past the end of a file runs a device EXCEPTION action that does a BREAK
	open "ydb1357e.txt":(newversion) use "ydb1357e.txt" write "one",! close "ydb1357e.txt"
	open "ydb1357e.m":(newversion) use "ydb1357e.m"
	write "ydb1357e"_$char(9)_"open ""ydb1357e.txt"":readonly use ""ydb1357e.txt"":exception=""use $principal break""",!
	write $char(9)_"read a read b",!
	write $char(9)_"use $principal write ""after the READ"",!",!
	write $char(9)_"quit",!
	close "ydb1357e.m"
	quit
exc
	;inp:"do ^ydb1357e"
	;inp:"tstart ()"
	;inp:"zcontinue"
	;inp:"write ""after the ZCONTINUE $tlevel="",$tlevel,!"
	;inp:"zshow ""s"""
	;inp:"trollback"
	;has:BREAKDEA
	;has:after the ZCONTINUE $tlevel=1
	;not:ERRWIOEXC
	;not:($ZTRAP)
