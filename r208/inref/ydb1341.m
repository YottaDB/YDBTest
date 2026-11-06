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
; Helper routines for the r208/trig_empty_pattern-ydb1341 subtest. Each label loads triggers whose subscript is a
; pattern, then checks the value $ZTRIGGER() returns and how many times the trigger runs for SETs of the global.
; It prints PASS or FAIL for each check.
;
ydb1341	;
	quit

empty	; ? with no pattern codes
	do load("?",0)
	quit

emptysemi	; ? with no pattern codes, followed by a ; and a value
	do load("?;1",0)
	quit

emptyalt	; an empty alternation
	do load("?1()",0)
	quit

emptyalt2	; an alternation of empty patterns
	do load("?1(,)",0)
	quit

valid	; patterns that are valid, including an alternation, a string literal and ?.E (which matches any subscript)
	do load("?1N;?1A",1)
	do load("?1(1""a"",1""bc"")",1)
	do load("?.E",1)
	quit

load(pat,expok)
	new ok,sub
	if $ztrigger("item","-*")
	kill ^x,^y
	set ok=$ztrigger("item","+^x("_pat_") -commands=set -xecute=""set ^y=$get(^y)+1""")
	do check(ok,expok,"$ZTRIGGER() return value for ^x("_pat_")")
	for sub=1,"a","bc","de" do update(sub)
	do check(+$get(^y),$select('expok:0,"?.E"=pat:4,1:2),"number of times the trigger ran")
	quit

update(sub)
	new $etrap
	set $etrap="write ""FAIL : SET ^x("",$zwrite(sub),"")=1 issued "",$zstatus,! set $ecode="""""
	set ^x(sub)=1
	quit

trgfile	; write a trigger file with the patterns that are not valid
	open "badpat.trg":newversion
	use "badpat.trg"
	write "+^x(?) -commands=set -xecute=""set ^y=1""",!
	write "+^x(?;1) -commands=set -xecute=""set ^y=1""",!
	write "+^x(?1()) -commands=set -xecute=""set ^y=1""",!
	write "+^x(?1(,)) -commands=set -xecute=""set ^y=1""",!
	close "badpat.trg"
	quit

check(got,exp,what)
	if got=exp write "PASS : ",what," is ",got,! quit
	write "FAIL : ",what," is ",got,", expected ",exp,!
	quit
