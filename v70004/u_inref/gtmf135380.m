;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main	; Main entry:
	; - set up locks (count: arg),
	; - print PID,
	; - wait until external stop request arrives.
	; This process keeps the LOCKs alive.
	;
	for i=1:1:$zcmdline lock +(^global(i))
	;
	write "pid:",$job,":",!
	;
	set ^state=1
	for  quit:^state=2  hang 0.1
	;
	quit

locked	; Entry: attempt to lock ^global(arg), should fail
	do att($zcmdline,"fail")
	quit

cleared	; Entry: attempt to lock ^global(arg), should succeed
	do att($zcmdline,"succeed")
	quit

att(index,should) ; attempt to lock ^global(index) with `should` result ("succeed" or "fail")
	;
	if index="" do  quit
	.write "arg is empty - test FAILED",!
	;
	set $etrap="do err(1) halt"
	;
	write "attempt to lock ^global(",index,") - "
lock	lock ^global(index):1
	if $test=0 do err(0) quit
	;
	write "lock succeed - test "
	if should="succeed" write "succeed",!
	if should="fail" write "FAILED",!
	quit
	;
err(showst) ;
	set sta=$zstatus
	set $etrap=""
	;
	write "lock failed - test "
	if should="succeed" write "FAILED",!
	if should="fail" write "succeed",!
	if showst=1 write "error: ",$piece(sta,",",2),!
	quit

procst	; process strace output, instead of reading syslog directly
	;
	for  do  quit:line=""
	.read line
	.if line="" quit
	.;
	.set known=0
	.if line["-E-RESTRICTSYNTAX" set known=1
	.if line["-E-RESTRICTEDOP" set known=1
	.if 'known quit
	.;
	.set syscall=$piece(line,"(",1)
	.if syscall'="sendto" quit
	.set line=$piece(line,"""",2)
	.set $piece(line,"%",1)=""
	.;
	.if $piece(line,"%",2)["-I-TEXT" do
	..set $piece(line,"%",2)=""
	..set line=$extract(line,2,9999)
	.;
	.for i=5:1:9 do
	..set p=$piece(line,"-",i)
	..if p["generated"&(p["0x") do
	...set $piece(line,"-",i)="generated from 0x<value_masked>"
	.;
	.do maskline
	quit

filtlke	; filter LKE output
	;
	set restrict=$piece($zcmdline," ",1)
	;
	for  do
	.read line
	.do maskline
	quit

maskline ; mask out stuff from line
	;
	for i=1:1:50 do
	.set p=$piece(line," ",i)
	.;
	.if p["restrict.txt" do
	..set $piece(line," ",i)="<path_masked>/restrict.txt"
	.;
	.if p["dlopen" do
	..set $piece(line," ",i)="LKE"
	;
	if line'="" write line,!
	quit
