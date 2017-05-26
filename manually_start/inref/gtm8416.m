;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set ($ecode,$zstatus)=""
	new $etrap
	set $etrap="goto eof"
	kill ^a		;KILL gets the process connected to the database so the extra time does not occur on the 1st SET below
	for i=1:1:$ztrnlnm("iterations") set h=$horolog hang 1 set ^x(1)=h
	zsystem "$gtm_exe/mupip journal -extract -noverify -forward mumps.mjl >& rollback.out"
	set f="mumps.mjf"
	open f:read
	use f:(rewind:exception="goto eof")
	; we expect the SET has a different journal time stamp than the $HOROLOG value picked up before the HANG 1
	for i=1:1 read line if 5=+line,$piece(line,"\\",2)=$piece(line,"^x(1)=",2),$increment(cnt)
eof	close f
	write !,$select($zstatus["IOEOF":$select('$get(cnt):"PASS",1:"FAILED "_cnt),1:$zstatus)," from ",$text(+0)
	quit
