;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1026	;
	; This is an automated test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1026#note_1560258223
	;
	set x=""
	for i=0:1:255 set x=x_$zchar(i)
	set $zpiece(x,x,1025)=""
	write "# Local variable [x] has value set to a long string with length [",$zlength(x),"]",!
	set f="ydb1026_f.out"
	write "# Doing [ZWRITE x] to file ",f,!
	open f:(newversion:stream)
	use f:(nowrap)
	zwrite x
	close f
	write "# Running [wc -l ",f,"]. Expect 1 in the first column (i.e. 1 line of output)",!
	write "# Before YDB@532b556a, it used to be 23 (much higher than 1)",!
	zsystem "wc -l "_f
	quit

