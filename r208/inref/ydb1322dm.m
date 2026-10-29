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
; Direct mode cases for the r208/zcompile_no_file-ydb1322 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1322dm
	quit

fileszcnofile	; A routine for the ZCOMPILE that prompts for its file name to compile
	open "okrtn.m":(newversion) use "okrtn.m" write " quit",! close "okrtn.m"
	quit
zcnofile
	;inp:"zcompile "" -nowarning abcd"""
	;inp:"zcompile "" -nowarning"""
	;inp:"okrtn.m"
	;inp:"write ""okrtn.o "",$select(""""=$zsearch(""okrtn.o""):""missing"",1:""exists""),!"
	;has:okrtn.o exists
	;not:FILEPARSE
	;not:FILEPATHTOOLONG
fileszcprompt2	; Two routines for the two ZCOMPILEs that each prompt for their file name to compile
	open "okrtn1.m":(newversion) use "okrtn1.m" write " quit",! close "okrtn1.m"
	open "okrtn2.m":(newversion) use "okrtn2.m" write " quit",! close "okrtn2.m"
	quit
zcprompt2
	;inp:"zcompile "" -nowarning"""
	;inp:"okrtn1.m"
	;inp:"zcompile "" -nowarning"""
	;inp:"okrtn2.m"
	;inp:"write ""okrtn1.o "",$select(""""=$zsearch(""okrtn1.o""):""missing"",1:""exists""),!"
	;inp:"write ""okrtn2.o "",$select(""""=$zsearch(""okrtn2.o""):""missing"",1:""exists""),!"
	;has:okrtn1.o exists
	;has:okrtn2.o exists
	;not:FILEPARSE
	;not:FILEPATHTOOLONG
