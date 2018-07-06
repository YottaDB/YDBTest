;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
tpnotacid
	tstart ():(serial:transaction="BA")
	if $trestart>2 hang .999
	else  do
	. set ^Y=$increment(^i)
	. zsystem "$ydb_dist/mumps -run ^%XCMD 'set ^Y=$increment(^i)'"
	tcommit
	quit

locktimeout
	set jmaxwait=0
	set ^X(1)=0
	set ^X(2)=0
	do ^job("lockchild^gtm5250",1,"""""")
	for  quit:^X(1)  hang 1
	lock ^A(1):1.234
	zwrite $test
	write:'$test "Lock successfully timed out",!
	set ^X(2)=1
	do wait^job
	quit

lockchild
	lock ^A
	set ^X(1)=1
	for  quit:^X(2)  hang 1
	lock
	quit

opentimeout
	set s="socket"
	open s:(connect="notreal.txt:LOCAL"):1.234:"SOCKET"
	zwrite $test
	write:'$test "Open succesffuly timed out",!
	quit
