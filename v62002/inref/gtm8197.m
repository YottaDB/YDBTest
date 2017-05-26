;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8197	; verify that trigger names over 30 characters retain their "triggerness" through truncation
	;
	new (act,debug)
	if '$data(act) new act set act="if $increment(cnt) use $principal zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="do ^incretrap",zl=$zlevel;,$zstep="zprint @$zposition zstep into"
	for file="t23456789012345678901234567890.m","t234567890123456789012345678901.m" do	; create files that might match
	. open file:newversion
	. use file
	. write "naughty ",file,!
	. close file
	write $text(+1^t234567890123456789012345678901#)
	set expect="TRIGNAMENF"
	zbreak ^t234567890123456789012345678901# set cnt=cnt+1
	zprint ^t234567890123456789012345678901# set cnt=cnt+1
	zbreak ^t2345678901234567890123456789012# set cnt=cnt+1
	zprint ^t2345678901234567890123456789012# set cnt=cnt+1
	zbreak ^t23456789012345678901234567890123# set cnt=cnt+1
	zprint ^t23456789012345678901234567890123# set cnt=cnt+1
	if '$ztrigger("item","+^a -commands=SET -xecute=""do ^twork"" -name=t234567890123456789012345678"),$incr(cnt) xecute act
	set expect="",x=$text(^t234567890123456789012345678#/DEFAULT)
	if " do ^twork"'=x,$increment(cnt) xecute act
	write !,$select('$get(cnt):"PASS",1:"FAIL")," from ",$text(+0)
	quit
	;
