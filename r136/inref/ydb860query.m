;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

	; This module contains entry points that are serially driven by ydb860.csh and checks
	; various $QUERY operations that used to get SIG-11s/Assert-failures in these uses prior to YDB#860
	;
ydb860query;
	quit

test1	;
	write "# test1 : Simple test of https://gitlab.com/YottaDB/DB/YDB/-/issues/860#note_946511877",!
	write "# This used to SIG-11/Assert failure before YDB@076f2ed6",!
	for c(1)=$query(c)
	write "# We expect zwrite to show c(1)=""""",!
	zwrite
	quit

test2	;
	write "# test2 : Simple test of https://gitlab.com/YottaDB/DB/YDB/-/issues/860#note_946513617",!
	write "# This used to SIG-11/Assert failure before YDB@721f274e",!
	for c(1)=$query(@"c")
	write "# We expect zwrite to show c(1)=""""",!
	zwrite
	quit

test3	;
	write "# test3 : And a fancy test of https://gitlab.com/YottaDB/DB/YDB/-/issues/860#note_946511877",!
	write "# This used to SIG-11/Assert failure before YDB@076f2ed6 and YDB@721f274e",!
	set c(3)="c(4)"
	set c(0)=$$func1
	write "# We expect zwrite to show c(0)=""c(1)"", c(1)=""c(2)"" etc. below",!
	zwrite
	quit

test4	;
	write "# test4 : Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/860#note_947042012",!
	write "# This used to return incorrect results before YDB@383640fc",!
	set c(1)="c(0)"
	set c(4)=$$reversefunc1
	write "# We expect zwrite to show c(1)=""c(0)"", c(2)=""c(1)"" etc. below",!
	zwrite
	quit

func1()
	for c(1)=$$func2
	quit $query(c)

func2()
	for c(2)=$query(c)
	quit $query(c)

reversefunc1()
	for c(3)=$$reversefunc2
	quit $query(c(5),-1)

reversefunc2()
	for c(2)=$query(c(5),-1)
	quit $query(c(5),-1)

