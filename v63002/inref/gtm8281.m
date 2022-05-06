;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Generating an m program which prints a string that is too long
;
genlongline
	set n=$piece($zcmdline," ",1)
	set file=$piece($zcmdline," ",2)
	open file
        use file write " write "
	write """"
	for i=1:1:$zcmdline do
	. write "a"
	write """"
	close file
	set y="check.out"
	open y
	use y
	for i=1:1:$zcmdline do
	. write "a"
	close y
	use $P  write "# temp.m contains big string",!
	quit

xecutefn
	xecute $zcmdline
	quit

dirmode
	set p="PipeProcess"
	open p:(command="$ydb_dist/mumps -dir")::"PIPE"
	use p
	write $zcmdline,!
	for  read x($increment(x))  quit:(x(x)["a")
	use $P  write x(x),!
	close p
	quit
