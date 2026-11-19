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
ydb1393	; Helper routine for the ctrap_zintr-ydb1393 subtest
	; Each entry point sets a CTRAP character on the principal device and a $ZINTERRUPT that runs a handler, writes
	; its pid so that the expect script can send it a MUPIP INTRPT, and waits for the handler to set "done". The
	; handler sets an $ETRAP that writes the error and sets "done", so a CTRAP error in the handler ends the wait just
	; as the end of the handler does.
	quit
loop	; The handler runs a loop of 4 seconds with no READ, during which the expect script types <CTRL-C>
	do start(3,"zloop^ydb1393")
	quit
read1	; The handler does a READ, in which the expect script types <CTRL-A>
	do start(1,"zread^ydb1393")
	quit
read3	; The handler does a READ, in which the expect script types <CTRL-C>
	do start(3,"zread^ydb1393")
	quit
plain	; No $ZINTERRUPT: a READ with each of $C(1), $C(2), $C(4) and $C(3) as the CTRAP character, in which the expect
	; script types that character, then a FOR loop, in which an event that a CTRAP left queued would be recognized
	new c,i,y
	set $etrap="write ""LATE ETRAP: "",$zstatus,! halt"
	for c=1,2,4,3 do plainread(c)
	write "LOOP START",!
	set y=0 for i=1:1:200000 set y=y+i
	write "LOOP DONE",!
	quit
plainread(c)
	new $etrap,x
	set $etrap="write ""ETRAP: "",$zstatus,! set $ecode="""" quit"
	use $principal:(ctrap=$char(c))
	write "PLAIN READ ",c,!
	read x
	write "PLAIN READ DONE ",c,!
	quit
start(char,handler)
	new done,i
	set done=0
	set $zinterrupt="do "_handler
	use $principal:(ctrap=$char(char))
	write "PID=",$job,!
	; Wait up to 60 seconds for the handler. The expect script gives up before that.
	for i=1:1:600 quit:done  hang 0.1
	write "MAIN END",!
	quit
zloop	; $ZINTERRUPT handler that runs a loop of 4 seconds with no READ
	new $etrap,t
	set $etrap="write ""ETRAP: "",$zstatus,! set $ecode="""",done=1 quit"
	write "ZINT LOOP",!
	set t=$zut for  quit:($zut-t)>4000000
	write "ZINT LOOP DONE",!
	set done=1
	quit
zread	; $ZINTERRUPT handler that does a READ
	new $etrap,x
	set $etrap="write ""ETRAP: "",$zstatus,! set $ecode="""",done=1 quit"
	write "ZINT READ",!
	read x
	write "ZINT READ DONE",!
	set done=1
	quit
