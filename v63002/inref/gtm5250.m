;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
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
	for i=1:1:10 do  quit:(diff>1.234)&(diff<1.434) ;Giving a .2 second window for the timeout to occur, doing the same for open timeout
	. set prev=$zut
	. lock ^A(1):1.23456 ;Also testing that fractional timeouts specified to more than 3 decimal places get truncated
	. set dollartest=$test
	. set cur=$zut
	. set diff=(cur-prev)*(10**-6)
	write "$TEST=",dollartest,!
	if (diff>1.234)&(diff<1.434)  write "Lock successfully timed out",!
	else  write "Lock failed to time out properly",!
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
	for i=1:1:10 do  quit:(diff>1.234)&(diff<1.434)
	. set prev=$zut
	. open s:(connect="notreal.txt:LOCAL"):1.2345:"SOCKET"
	. set dollartest=$test
	. set cur=$zut
	. set diff=(cur-prev)*(10**-6)
	write "$TEST=",dollartest,!
	if (diff>1.234)&(diff<1.434)  write "Open successfully timed out",!
	else  write "Open failed to time out properly",!
	quit
