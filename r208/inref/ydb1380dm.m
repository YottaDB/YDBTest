;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Direct mode cases for the r208/zstep_queued_ztimeout-ydb1380 subtest, run by r208/u_inref/ydbfuzzdm.csh. The stages of
; that subtest describe the cases.
;
ydb1380dm
	quit

filesdmfor
	open "ydb1380r.m":(newversion) use "ydb1380r.m" write "ydb1380r"_$char(9)_"write ""in ydb1380r"",!",!,$char(9)_"quit",! close "ydb1380r.m"
	quit
dmfor
	;inp:"set $ztimeout=0"
	;inp:"zstep"
	;inp:"for  set x=1"
	;inp:"write ""after the FOR"",!"
	;has:ZTIMEOUT
	;has:after the FOR
filesdmrtn
	open "ydb1380r.m":(newversion) use "ydb1380r.m" write "ydb1380r"_$char(9)_"write ""in ydb1380r"",!",!,$char(9)_"quit",! close "ydb1380r.m"
	quit
dmrtn
	;inp:"set $ztimeout=""0:write """"ZT vector"""",!"""
	;inp:"zstep"
	;inp:"do ^ydb1380r"
	;inp:"write ""after the DO"",!"
	;has:ZT vector
	;has:in ydb1380r
	;has:after the DO
