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
; Direct mode cases for the r208/syntax_err_after_warn-ydb1330 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1330dm
	quit

filesswcompile	; A routine whose lines have an invalid special variable name followed by a syntax error
	open "warn.m":(newversion) use "warn.m"
	write "warn",!," write:$foo-1 ",!," new $ms o       set $et=""do etr""",!," quit",!
	close "warn.m"
	quit
swsvn
	;inp:"write:$foo-1 "
	;has:EXPR
	;not:INDRCOMPFAIL
swsvn2
	;inp:"new $ms o       set $et=""do etr"""
	;has:EXPR
	;not:INDRCOMPFAIL
swfcn
	;inp:"set @(""$zinterruvprjreq($zposition)"""""")"
	;has:RPARENMISSING
	;not:INDRCOMPFAIL
swfcn2
	;inp:"set $zfoo(1"")=2"
	;inp:"xecute ""set $zfoo(1"""")=2"""
	;inp:"set (a,$zfoo(1""))=2"
	;inp:"set $zfoo(1""),b=2"
	;inp:"write ""after the SET lines"",!"
	;has:after the SET lines
	;not:CMD
swcompile
	;inp:"zcompile ""warn.m"""
	;inp:"write ""warn.o "",$select(""""=$zsearch(""warn.o""):""missing"",1:""exists""),!"
	;has:EXPR
	;has:warn.o exists
filesswfcncompile	; A routine whose lines have an invalid function name as a SET target followed by an unterminated string literal
	open "fcn.m":(newversion) use "fcn.m"
	write "fcn",!," set $zfoo(1"")=2",!," set (a,$zfoo(1""))=2",!," quit",!
	close "fcn.m"
	quit
swfcncompile
	;inp:"zcompile ""fcn.m"""
	;inp:"write ""fcn.o "",$select(""""=$zsearch(""fcn.o""):""missing"",1:""exists""),!"
	;has:INVFCN
	;has:fcn.o exists
	;not:CMD
