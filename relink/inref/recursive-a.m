;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
a	;
	view "LINK":"RECURSIVE"
	write "version 1",!
	if $incr(i)>1 write "ERROR",! halt
	zlink "b"
	zsystem "cp a.edit.m aedit.m; $ydb_dist/mumps -nameofrtn=a aedit.m"
	zlink "a.o"
	do ^b
	write $view("RTNCHECKSUM","a"),!
	quit
