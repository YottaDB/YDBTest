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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002181	;
	set rtn="test"_+$zcmdline_"^c002181"
	set pipe="pipe"
	open pipe:(command="$gtm_dist/mumps -run "_rtn)::"pipe"
	use pipe
	for i=1:1  read line(i):1 quit:$zeof  if line(i)["YDB>" write "zwrite $zstatus halt",!
	use $p
	for i=1:1:$order(line(""),-1)  if $length(line(i)) write line(i),!
	quit
rtns;c002181a,c002181b,c002181c,c002181d,c002181e
	;
	; Following is a lot of testcases that demonstrated the issue in C9C11-002181
	; Although most of them exercise similar code, we include all the tests just to be safe.
	;
test1	;
	do ^c002181a
	write "$zlevel at end of c002181a = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
test2	;
	do ^c002181b
	write "$zlevel at end of c002181b = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
test3	;
	do ^c002181c
	write "$zlevel at end of c002181c = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
test4	;
	do ^c002181d
	write "$zlevel at end of c002181d = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
test5	;
	do ^c002181e
	write "$zlevel at end of c002181e = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
test6	;
	do ^c002181f
	write "$zlevel at end of c002181f = ",$zlevel,!
	if $zversion'["VMS" zwrite $zstatus
	quit
