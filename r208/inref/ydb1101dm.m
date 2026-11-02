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
; Direct mode cases for the r208/fuzz_asserts-ydb1101 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1101dm
	quit

fileszccross	; A routine with no code, to compile with $ZCOMPILE=" -c"
	open "foo.m":(newversion) use "foo.m" write " ",! close "foo.m"
	quit
fadollar
	;inp:"set r=%*$$""foo"
	;inp:"write $$extrin(-$$"")"
	;inp:"write $$indrq(,$$"")"
	;has:RTNNAME
fapat
	;inp:"set x=""^A"",y=x?@"".write i,!"
	;has:EXPR
faatsign
	;inp:"set a=""@""_$char(128)_""(66)"",a(2)=""(@a,d)"",b=""a"",c(2)=""c(2)"""
	;inp:"new @@b@(2)"
	;has:EXPR
fazwrtac
	;inp:"set $ZWRTAC9999999"""
	;has:VAREXPECTED
faview
	;inp:"write ""$view(4 args)="",$view(""REGION"",""^efghLLATE"",1,1),!"
	;has:$view(4 args)=DEFAULT
faecode
	;inp:"set y="",M10"" for i=1:1:12 set y=y_y"
	;inp:"write ""$length(y_y_"""","""")="",$length(y_y_"",""),!"
	;inp:"set $ecode=y_y_"","""
	;inp:"write ""after SET $ECODE"",!"
	;has:$length(y_y_",")=32769
	;has:SETECODE
	;has:after SET $ECODE
zccross
	;inp:"set $zcompile="" -c"""
	;inp:"zcompile ""foo.m"""
	;inp:"write ""foo.o "",$select(""""=$zsearch(""foo.o""):""missing"",1:""exists""),!"
	;inp:"write ""foo.lis "",$select(""""=$zsearch(""foo.lis""):""missing"",1:""exists""),!"
	;has:foo.o exists
	;has:foo.lis exists
