;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nestederror
	do main	; an extra dummy M frame is needed to see the rethrown tcommitDISALLOW error
	quit

main	;
	do ^sstep
	set errtype=$select($zcmdline'="":$zcmdline,1:0)
	if errtype'?.N  halt
	new $ztrap
	set $etrap="do etr^nestederror("_errtype_")"
	tstart ()
	for i=1:1:10 set $piece(^a(i),",",1)=i,$piece(^a(i),",",2)=i*5
	tcommit
	zwr ^b zwr ^d
	tstart ()
	for i=1:2:10 zkill ^b(i)
	tcommit
	zwr ^b zwr ^d
	quit

etr(err)	;
	write $zstatus,!
	if err=0 tcommit
	if err=1&$tlevel tcommit
	if err=2&$tlevel trollback
	set $ecode=""
	quit
